import sql, { withTenantTransaction } from "@/lib/database"
import { INTERNAL_VOUCHER, JOURNAL_LINE_TYPE, createAutoJournal, getBaseCurrencyId, getRateByDate } from "@/lib/auto-journals"
import { JOURNAL_TYPE_CHEQUE, PAYMENT_VCH_TYPE, RECEIPT_VCH_TYPE, getVoucherNumberSettings, nextVoucherSequence, resolveVoucherBookName } from "@/app/api/receipts/_lib"
import { buildVoucherCode } from "@/lib/voucher-code"
import { withYearOpened } from "@/lib/year-end-closing"
import { StepContext, date, insertRow, mapOne, mapSet, num, text } from "@/lib/shamel-migration/core"
import { accountId, currencyId } from "@/lib/shamel-migration/definitions"
import { voucherBookFor } from "@/lib/shamel-migration/balances"

// شيكات السنوات السابقة (cheques."Prev. year" ≠ 0) — نفس إجراء الشامل ويب (MigratePreviousChequesF):
// 1) سند قبض (شيك وارد) أو سند صرف (شيك صادر) يحمل الشيك: مدين/دائن حساب الشيكات مقابل حساب العميل/المورد،
//    فيُسجَّل الشيك في سجل الشيكات بحالته في الشامل (previous_year = 1).
// 2) سند قيد عكسي بنفس التاريخ يُلغي أثر السند على الأرصدة — أرصدة الحسابات رُحِّلت أصلاً في الأرصدة الافتتاحية.
// الاتجاه: Type = 1 بالشامل أو سند صادر (رقم السند يبدأ بـ P) ⇐ صادر؛ غير ذلك ⇐ وارد. (في بيانات الشامل الفعلية
// Type = 0 دائماً حتى للشيكات الصادرة، والفرق هو بادئة السند R/P — نفس ما يعتمده الشامل ويب.)

type Row = Record<string, unknown>

/** حالة الشيك بالشامل ⇐ cheque_status_tbl (نفس GetCheqStatus بالشامل ويب) */
const CHEQUE_STATUS: Record<number, number> = { 0: 1, 1: 3, 2: 4, 3: 5, 4: 6, 5: 7, 6: 8, 7: 2, 8: 9 }

export const previousChequesSql = () => `select cq."Voucher ID" as cheq_vch_code, cq."Type" as cheq_type, cq."Cheq. num." as cheq_num,
  case when cq."Received date">'1990-01-01' then cq."Received date" else '1990-01-01' end as received_date,
  case when cq."Date">'1990-01-01' then cq."Date" else '1990-01-01' end as cheq_date,
  case when cq."Due date">'1990-01-01' then cq."Due date" else '1990-01-01' end as cheq_due_date,
  case when cq."Pay date">'1990-01-01' then cq."Pay date" else '1990-01-01' end as cheq_pay_date,
  case when cq."Return date">'1990-01-01' then cq."Return date" else '1990-01-01' end as cheq_return_date,
  case when cq."Hold date">'1990-01-01' then cq."Hold date" else '1990-01-01' end as cheq_hold_date,
  case when cq."First due date">'1990-01-01' then cq."First due date" else '1990-01-01' end as first_due_date,
  cq."Bank ID" as bank_code, cq."Branch ID" as branch_code, cq."Account" as account_code, cq."Our acc." as our_account_code,
  cq."Cust. ID" as customer_code, cq."RecCheqAcc" as recieved_cheq_account, cq."Currency" as cheq_currency_code,
  cq."Bank acc." as cheq_bank_account_code, cq."SalesMan ID" as cheq_salesman_code, cq."Amount" as cheq_amount, cq."Rate" as cheq_rate,
  cq."Status" as cheq_status, cq."NumOfRet." as cheq_num_of_returns, cq."Manualy" as manualy, cq."CheqOwnerName" as cheq_owner_name
  from "cheques" cq where cq."Prev. year" <> 0 order by cq."Voucher ID", cq."Cheq. num."`

async function journalLine(voucherId: number, orderNo: number, journalTypeId: number, account: number, creditDebit: 1 | 2,
  amount: number, currency: number, rate: number, day: string, baseCurrencyId: number | null) {
  const accountRow = (await sql`SELECT currency_id FROM account_tbl WHERE id = ${account}`)[0] as any
  const base = Math.round(amount * rate * 1000) / 1000
  const accountCurrency = accountRow?.currency_id != null ? Number(accountRow.currency_id) : currency
  const accountRate = accountCurrency === currency ? rate : accountCurrency === baseCurrencyId ? 1 : (await getRateByDate(accountCurrency, day, baseCurrencyId)) || 1
  const accountAmount = accountCurrency === currency ? amount : Math.round((base / accountRate) * 1000) / 1000
  await sql`
    INSERT INTO voucher_journal_detail_tbl (
      voucher_id, order_no, journal_type_id, account_id, credit_debit, amount, currency_id, rate, base_curr_amount,
      account_currency_id, account_rate, account_amount, note
    ) VALUES (
      ${voucherId}, ${orderNo}, ${journalTypeId}, ${account}, ${creditDebit}, ${amount}, ${currency}, ${rate}, ${base},
      ${accountCurrency}, ${accountRate}, ${accountAmount}, ${"شيكات من سنة سابقة"}
    )`
}

export async function processPreviousCheques(rows: Row[], ctx: StepContext) {
  const baseCurrencyId = await getBaseCurrencyId()
  const books = new Map<number, number | null>()
  for (const row of rows) {
    ctx.stats.received++
    const cheqNum = text(row.cheq_num)
    // رقم سند شيكات السنوات السابقة بالشامل ثابت غالباً (R0000000) ونفس رقم الشيك يتكرر لبنوك/حسابات مختلفة —
    // الشيك يُعرَّف برقمه + بنكه وفرعه + رقم حساب الساحب + العميل
    const key = [text(row.cheq_vch_code), cheqNum, text(row.bank_code), text(row.branch_code), text(row.account_code), text(row.customer_code)].join("|")
    try {
      if (!cheqNum) { ctx.stats.skipped++; continue }
      if (await mapOne("prev_cheque", key)) { ctx.stats.skipped++; continue }
      const outgoing = num(row.cheq_type) === 1 || text(row.cheq_vch_code).toUpperCase().startsWith("P")
      const vchType = outgoing ? PAYMENT_VCH_TYPE : RECEIPT_VCH_TYPE
      const amount = Math.round(Math.abs(num(row.cheq_amount)) * 1000) / 1000
      if (!(amount > 0)) { ctx.stats.skipped++; continue }
      const party = await accountId(row.customer_code)
      if (!party) throw new Error(`حساب العميل/المورد ${text(row.customer_code)} غير موجود`)
      const chequeAccount = (await accountId(row.recieved_cheq_account)) || (await accountId(row.our_account_code))
      if (!chequeAccount) throw new Error(`حساب الشيكات ${text(row.recieved_cheq_account)} غير موجود`)
      const currency = (await currencyId(row.cheq_currency_code)) || baseCurrencyId || 1
      const day = date(row.received_date) || date(row.cheq_date) || ctx.run.balance_date
      const rate = currency === baseCurrencyId ? 1 : num(row.cheq_rate) || (await getRateByDate(currency, day, baseCurrencyId)) || 1
      if (!books.has(vchType)) books.set(vchType, await voucherBookFor(ctx.run.created_by, vchType))
      const bookId = books.get(vchType) ?? null
      if (!bookId) throw new Error(`لا يوجد دفتر سندات لـ ${outgoing ? "سند الصرف" : "سند القبض"} — عرّفه من صلاحيات دفاتر السندات`)
      const bankId = await mapOne("bank", text(row.bank_code))
      const branchId = await mapOne("bank_branch", `${text(row.bank_code)}${text(row.branch_code)}`)
      const bankAccountId = text(row.cheq_bank_account_code) ? await mapOne("bank_account", text(row.cheq_bank_account_code)) : null
      const salesman = text(row.cheq_salesman_code) ? await mapOne("salesman", text(row.cheq_salesman_code)) : null
      const partyName = text((await sql`SELECT name FROM account_tbl WHERE id = ${party}`)[0]?.name)

      await withTenantTransaction(() => withYearOpened(Number(day.slice(0, 4)), async () => {
        // 1) سند القبض/الصرف بالشيك
        await sql`SELECT pg_advisory_xact_lock(hashtext(${`receipt-number:${vchType}`}))`
        const { prefix, startNumber } = await getVoucherNumberSettings("", vchType)
        const bookName = await resolveVoucherBookName(bookId, ctx.run.branch_id)
        const sequence = await nextVoucherSequence(vchType, `${prefix}${bookName}`, startNumber)
        const vchCode = buildVoucherCode(prefix, bookName, sequence)
        const voucherId = await insertRow("voucher_header_tbl", {
          vch_type: vchType, vch_code: vchCode, vch_date: day, manual_date: day, vch_book_id: bookId, branch_id: ctx.run.branch_id,
          currency_id: currency, rate, account_id: party, customer_name: partyName.slice(0, 150) || null, amount,
          salesman_id: salesman, manual_voucher: text(row.cheq_vch_code).slice(0, 50), note: "شيكات من سنة سابقة",
          status: 2, vch_status: 2, is_printed: 0,
        })
        // سند قبض: مدين حساب الشيكات / دائن العميل — سند صرف: العكس
        await journalLine(voucherId, 1, JOURNAL_TYPE_CHEQUE, chequeAccount, outgoing ? 2 : 1, amount, currency, rate, day, baseCurrencyId)
        await journalLine(voucherId, 2, JOURNAL_LINE_TYPE, party, outgoing ? 1 : 2, amount, currency, rate, day, baseCurrencyId)
        await insertRow("cheques_tbl", {
          voucher_id: voucherId, cheq_type: outgoing ? 2 : 1, bank_account: text(row.account_code), bank_account_id: bankAccountId,
          cheq_num: cheqNum, bank_id: bankId, branch_id: branchId, amount, currency_id: currency, rate,
          received_date: day, trans_date: day, due_date: date(row.cheq_due_date), pay_date: date(row.cheq_pay_date),
          return_date: date(row.cheq_return_date), hold_date: date(row.cheq_hold_date), first_due_date: date(row.first_due_date),
          customer_id: party, rec_cheq_account_id: chequeAccount, current_account_id: chequeAccount, salesman_id: salesman,
          cheq_owner_name: text(row.cheq_owner_name), status_id: CHEQUE_STATUS[num(row.cheq_status)] ?? 9,
          return_count: num(row.cheq_num_of_returns), previous_year: 1, manual_insert: num(row.manualy) ? 1 : 0,
          is_printed: 0, last_update_date: day, order_no: 1,
        })
        // 2) قيد عكسي: يُعيد الأرصدة كما رُحِّلت بالأرصدة الافتتاحية
        await createAutoJournal({
          userId: ctx.run.created_by, branchId: ctx.run.branch_id, date: day, currencyId: currency, rate,
          note: `شيكات من سنة سابقة - قيد عكسي لسند ${vchCode} (شيك ${cheqNum})`, internalVoucherId: INTERNAL_VOUCHER.OPENING_BALANCE,
          manualVoucher: vchCode,
          lines: [
            { accountId: chequeAccount, creditDebit: outgoing ? 1 : 2, amount, currencyId: currency, rate, note: `شيك ${cheqNum}` },
            { accountId: party, creditDebit: outgoing ? 2 : 1, amount, currencyId: currency, rate, note: `شيك ${cheqNum}` },
          ],
        })
        await mapSet("prev_cheque", key, voucherId)
      }))
      ctx.stats.created++
    } catch (error) {
      ctx.error(`${text(row.cheq_vch_code)} / ${cheqNum}`, error instanceof Error ? error.message : String(error))
    }
  }
}
