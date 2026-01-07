# WhatsApp Notifications for Inventory Reorder

This feature automatically sends WhatsApp notifications when inventory items reach their reorder point.

## Setup

### 1. Database Setup

Run the SQL script to create the necessary tables:

\`\`\`bash
# The script is located at: scripts/001_create_whatsapp_notification_tables.sql
# It will be automatically executed when you run it from the v0 interface
\`\`\`

### 2. Twilio Configuration

The following environment variables are already configured:
- `TWILIO_ACCOUNT_SID` - Your Twilio Account SID
- `TWILIO_AUTH_TOKEN` - Your Twilio Auth Token
- `TWILIO_PHONE_NUMBER` - Your Twilio phone number
- `TWILIO_WHATSAPP_NUMBER` - Your Twilio WhatsApp number (format: +1234567890)

### 3. Configure Notifications

1. Navigate to **Inventory** → **WhatsApp Notification Settings**
2. Enable notifications using the toggle switch
3. Add phone numbers (format: +966501234567)
4. Customize the message template using variables:
   - `{product_name}` - Product name
   - `{product_code}` - Product code
   - `{current_stock}` - Current stock level
   - `{reorder_point}` - Reorder point threshold
   - `{supplier_name}` - Supplier name
5. Optionally enable daily summary reports
6. Click **Save Settings**

## Features

### Automatic Notifications
- Checks inventory levels every 6 hours (configurable in vercel.json)
- Sends WhatsApp messages when products reach reorder point
- Prevents duplicate notifications within 24 hours
- Logs all notification attempts with status tracking

### Manual Notifications
- Click **Send Notifications Now** button to trigger immediate check
- Useful for testing or urgent inventory checks

### Notification Log
- View history of all sent notifications
- Track success/failure status
- See error messages for failed notifications
- Filter and search notification history

## Cron Job Setup

The system uses Vercel Cron Jobs to automatically check inventory:

\`\`\`json
{
  "crons": [
    {
      "path": "/api/cron/check-inventory",
      "schedule": "0 */6 * * *"
    }
  ]
}
\`\`\`

Schedule format (cron expression):
- `0 */6 * * *` - Every 6 hours
- `0 9 * * *` - Daily at 9:00 AM
- `0 */1 * * *` - Every hour

### Optional: External Cron Service

If you prefer using an external service like cron-job.org:

1. Add `CRON_SECRET` environment variable for security
2. Configure the external service to call:
   \`\`\`
   GET https://your-domain.com/api/cron/check-inventory
   Authorization: Bearer YOUR_CRON_SECRET
   \`\`\`

## API Endpoints

### Get Notification Settings
\`\`\`
GET /api/inventory/notification-settings
\`\`\`

### Save Notification Settings
\`\`\`
POST /api/inventory/notification-settings
Body: {
  is_enabled: boolean,
  phone_numbers: string[],
  message_template: string,
  send_daily_summary: boolean,
  daily_summary_time: string
}
\`\`\`

### Send Notifications
\`\`\`
POST /api/inventory/send-reorder-notifications
\`\`\`

### Get Notification Log
\`\`\`
GET /api/inventory/send-reorder-notifications?limit=20
\`\`\`

### Cron Job Endpoint
\`\`\`
GET /api/cron/check-inventory
Authorization: Bearer CRON_SECRET (optional)
\`\`\`

## Troubleshooting

### Notifications Not Sending

1. **Check Twilio Configuration**
   - Verify all Twilio environment variables are set
   - Ensure WhatsApp number is properly formatted
   - Check Twilio console for any account issues

2. **Check Notification Settings**
   - Ensure notifications are enabled
   - Verify phone numbers are in correct format (+country_code + number)
   - Check that message template is not empty

3. **Check Product Configuration**
   - Ensure products have `reorder_point` set
   - Verify products are marked as `active`
   - Check that `product_stock` table has current stock data

4. **Review Notification Log**
   - Check for error messages in the log
   - Look for failed notifications and their reasons

### Testing

1. Set a product's reorder point above its current stock
2. Click **Send Notifications Now**
3. Check the notification log for results
4. Verify WhatsApp message was received

## Security Notes

- Phone numbers are stored in the database
- Twilio credentials are stored as environment variables
- Optional CRON_SECRET for securing automated checks
- All API endpoints should be protected with authentication in production
