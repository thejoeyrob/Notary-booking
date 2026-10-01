# Indiana Notary Services — Premium Booking PWA

This package is designed to be committed to GitHub and deployed to **Vercel**. Vercel is the recommended host because the appointment desk, email delivery, secure admin login, distance calculation and PDF correspondence use serverless API routes. GitHub can hold the repository and can host the static public UI, but GitHub Pages alone cannot run the secure backend functions.

## Included

- Premium responsive public website and installable PWA.
- Month-calendar booking flow with 15-minute time slots.
- Automatic unavailable-slot greying for confirmed bookings and manually/imported busy times.
- Customer fields: name, phone, email, service/document type, number of notarial acts, notes and meeting address.
- Automatic road-distance calculation from a **private base address**. Customers only see mileage.
- 20-mile service-area rule with a suggested meeting area on the route when the destination is outside the radius.
- Live price estimate: notarial acts + mileage.
- Automatic request reference and request-receipt email.
- Private admin area. Default requested PIN: **2403**.
- Request / confirmed-unpaid / confirmed-paid lists.
- Admin response composer with confirm, alternative time, more information, decline and custom responses.
- Branded PDF attachment for customer correspondence.
- All correspondence stored against the booking.
- Configurable forwarding email, public email/phone, base address, fees, hours, slot interval, payment links and response templates.
- Confirmed booking `.ics` download for adding to Apple Calendar / Outlook / Google Calendar.
- `.ics` busy-time import for blocking times from a smartphone/calendar export.

## Important calendar limitation

A normal website/PWA is **not permitted to read a private iPhone calendar directly**. This build therefore supports:

1. 15-minute availability generated from the business hours stored in Admin.
2. Automatic blocking of confirmed appointments.
3. Manual busy-time blocking in Admin.
4. `.ics` calendar import to bring existing busy events into the availability engine.
5. `.ics` download for confirmed appointments.

A later native iPhone app or an authenticated Google/Microsoft calendar integration can provide continuous two-way calendar sync. Publishing a private iCloud calendar as a public feed is not recommended merely to obtain automatic sync.

## Business details carried over from the supplied reference build

- Kalie Kearney-Dunkerson — Indiana Notary Public.
- Fairland, Indiana / ZIP 46126 service base.
- Approximate 20-mile mobile service area.
- Phone: 317-728-7537.
- Email / initial appointment recipient: IndianaNotaryServices@gmail.com.
- Weekdays: 5:00 PM–9:00 PM.
- Weekends: 7:00 AM–9:00 PM.
- Same-day requests welcome, subject to availability.
- $10 per notarial act.
- $0.76 per mile travel rate.
- Venmo / Square electronic payment; no cash workflow in the booking form.

The public design was rebuilt from scratch; the supplied old site was used for business particulars only.

## 1. Create Supabase database

Create a Supabase project, open **SQL Editor**, and run the entire file:

`supabase-schema.sql`

The schema has Row Level Security enabled with **no public policies**. The browser never receives the Supabase service-role key. All access runs through the Vercel API.

## 2. Create a Resend account for email

For testing, Resend can send only within its testing restrictions. After the business domain is bought, verify the domain in Resend and use a sender such as:

`Indiana Notary Services <appointments@yourdomain.com>`

The forwarding/recipient address can be changed at any time inside the Admin area without code changes.

## 3. Deploy to Vercel

1. Put all files from this folder at the root of a GitHub repository.
2. In Vercel, choose **Add New → Project** and import that repository.
3. Framework preset: **Other**.
4. No build command is required.
5. Add these Environment Variables:

```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY
ADMIN_PIN=2403
ADMIN_SESSION_SECRET=use-a-long-random-string-here
RESEND_API_KEY=re_xxxxxxxxx
MAIL_FROM=Indiana Notary Services <appointments@yourdomain.com>
```

6. Deploy.

## 4. Admin area

Open:

`https://your-domain.com/admin.html`

Default PIN: **2403**

For security, the PIN is checked server-side. Do not put the Supabase service-role key, Resend key or admin secret in any browser JavaScript file.

### Recommended first Admin changes

- Set the **private mileage start address** to the exact business starting address. It is used for routing but never displayed to customers.
- Confirm forwarding email.
- Add Square and Venmo payment links.
- Review confirmation and alternative-time templates.
- Import existing busy times with an `.ics` file if required.

## 5. Domain

When the domain is purchased, attach it in Vercel and then update the verified sender domain in Resend. No code changes are required for the public URL.

## Distance calculation

The starter build uses OpenStreetMap Nominatim for geocoding and OSRM for road routing. This keeps the first deployment key-free. For high booking volume, replace these with a commercial routing/geocoding provider in `api/distance.js` to obtain an SLA and higher request limits.

## Legal/pricing note

Indiana guidance states a notary may charge up to $10 per individual notarization and may separately charge travel up to the federal mileage rate. The package keeps the supplied $10 act fee and $0.76/mile rate editable in Admin. Review fees whenever Indiana or federal mileage rules change.

## File map

- `index.html` — public website.
- `booking.html` — customer booking app.
- `admin.html` — appointment desk.
- `assets/` — public/admin CSS and JavaScript.
- `api/` — Vercel serverless backend.
- `supabase-schema.sql` — database setup.
- `.env.example` — environment variable template.
- `manifest.webmanifest`, `sw.js`, `icons/` — PWA install assets.
