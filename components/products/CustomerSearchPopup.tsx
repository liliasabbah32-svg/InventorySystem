"use client";

import React, { useState, useEffect, useRef, useMemo, useCallback } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import DataGrid from "../common/DataGrid";
import * as wjGrid from "@grapecity/wijmo.grid";
import DataGridView from "../common/DataGridView";

interface Customer {
    id: number;
    customer_code: string;
    name: string;
    mobile1: string;
    general_notes: string;
    pricecategory: number;
}

interface CustomerSearchPopupProps {
    visible: boolean;
    onClose: () => void;
    onSelect: (customer: Customer) => void;
    type: number;
}

const CustomerSearchPopup: React.FC<CustomerSearchPopupProps> = ({ visible, onClose, onSelect, type }) => {
    const [customers, setCustomers] = useState<Customer[]>([]);
    const [searchTerm, setSearchTerm] = useState("");
    const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
    const gridRef = useRef<wjGrid.FlexGrid | null>(null);
    const searchInputRef = useRef<HTMLInputElement>(null);

    // Load customers
    useEffect(() => {
        if (!visible) return;
        let cancelled = false;

        const fetchCustomers = async () => {
            let cancelled = false;

            try {
                const response = await fetch("/api/customers");
                const data = await response.json();

                if (!cancelled) {
                    // Ensure we have an array
                    const allRecords = Array.isArray(data) ? data : data.customers || [];

                    // Filter by type: 1 = customer, 2 = supplier
                    const filtered = type === -1
                        ? allRecords
                        : allRecords.filter((c: any) => c.type === type);

                    // Order by customer_code
                    filtered.sort((a: any, b: any) =>
                        a.customer_code.localeCompare(b.customer_code)
                    );

                    // Map to match grid column names
                    const mapped = filtered.map((c: any, index: number) => ({
                        ser: index + 1,
                        id: c.id,
                        customer_code: c.customer_code,
                        name: c.name,
                        mobile1: c.mobile1,
                        general_notes: c.general_notes || "",
                        pricecategory: c.pricecategory || 1
                    }));

                    setCustomers(mapped);
                }
            } catch (err) {
                console.error("Failed to fetch customers:", err);
                if (!cancelled) setCustomers([]);
            }
        };


        fetchCustomers();
        return () => {
            cancelled = true;
        };
    }, [visible]);

    // Focus search input
    useEffect(() => {
        if (visible) setTimeout(() => searchInputRef.current?.focus(), 0);
    }, [visible]);


    // Search filter
    const searchWordsMatch = (text: string, query: string) => {
        const words = query.trim().toLowerCase().split(/\s+/);
        const normalizedText = (text || "").toLowerCase();
        return words.every((word) => normalizedText.includes(word));
    };

    const filteredCustomers = useMemo(() => {
        if (!searchTerm.trim()) return customers;
        return customers.filter(
            (c) =>
                searchWordsMatch(c.name, searchTerm) ||
                searchWordsMatch(c.customer_code, searchTerm) ||
                searchWordsMatch(c.mobile1, searchTerm)
        );
    }, [customers, searchTerm]);

    // DataGrid scheme
    const customerScheme = useMemo(() => ({
        name: "CustomersScheme",
        filter: false,
        showFooter: true,
        sortable: true,
        allowGrouping: false,
        columns: [
            { header: "##", name: "ser", width: 50 },
            { header: type === 1 || type === -1 ? "رقم الزبون" : "رقم المورد", name: "customer_code", width: 120 },
            { header: type === 1 || type === -1 ? "اسم الزبون" : "اسم المورد", name: "name", width: "*" },
            { header: "الجوال", name: "mobile1", width: 130 },
            { header: "ملاحظات", name: "general_notes", width: 200 },
        ],
    }), []);

    // Row click / double click
    const handleRowClick = useCallback((customer: Customer) => setSelectedCustomer(customer), []);
    const handleRowDoubleClick = useCallback((customer: Customer) => { onSelect(customer); onClose(); }, [onSelect, onClose]);
    const handleAccept = useCallback(() => { if (selectedCustomer) { onSelect(selectedCustomer); onClose(); } }, [selectedCustomer, onSelect, onClose]);

    useEffect(() => {
        if (!visible) return;

        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape") {
                e.preventDefault();
                onClose();
            }
            if (e.key === "Enter") {
                e.preventDefault();
                if (selectedCustomer) {
                    handleRowDoubleClick(selectedCustomer); // Accept selected order
                }
            }
        };

        window.addEventListener("keydown", handleKeyDown, true);

        return () => {
            window.removeEventListener("keydown", handleKeyDown, true);
        };
    }, [visible, onClose, handleRowDoubleClick, selectedCustomer]);
    if (!visible) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
            <div
                className="bg-white rounded-lg shadow-2xl border p-6 flex flex-col w-full max-w-4xl"
                dir="rtl"
                style={{ height: "600px" }}
            >
                <h3 className="text-lg font-semibold mb-4 text-right">
                    {type === 1 || type === -1 ? "بحث الزبائن" : "بحث الموردين"}
                </h3>

                <Input
                    type="text"
                    placeholder={type === 1 || type === -1 ? "ابحث عن زبون..." : "ابحث عن مورد"}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="mb-4 p-2 border border-gray-300 rounded w-full text-right"
                    ref={searchInputRef}
                />

                <div className="flex-1 flex flex-col gap-4 overflow-hidden">
                    <div className="flex-1 overflow-hidden border rounded shadow-sm p-2">
                        <div className="min-w-max overflow-x-auto">
                            <DataGridView
                                ref={(g: any) => (gridRef.current = g?.control ?? g ?? null)}
                                isReport={true}
                                dataSource={filteredCustomers}
                                scheme={customerScheme}
                                onRowClick={handleRowClick}
                                onRowDoubleClick={handleRowDoubleClick}

                            />
                        </div>
                    </div>
                </div>

                <div className="flex justify-center gap-2 mt-4">
                    <Button className="erp-btn-primary" onClick={() => selectedCustomer && handleRowDoubleClick(selectedCustomer)} >
                        موافق
                    </Button>
                    <Button variant="outline" onClick={onClose}>إغلاق</Button>
                </div>
            </div>
        </div>
    );
};

export default CustomerSearchPopup;
