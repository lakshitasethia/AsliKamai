# AsliKamai Privacy Policy

_Last updated: 24 September 2026_

AsliKamai helps delivery and ride-hailing gig workers in Karnataka see their real net
earnings, catch pay-rate cuts, and keep evidence for disputes. It is built to work without an
account and to keep your data on your phone. Cloud backup is optional and off until you sign
in.

## What the app stores, and where

Everything you record stays in the app's private storage on your phone:

- orders and payouts read from screenshots you choose
- expenses you type or speak
- evidence photos and screenshots, with their date and fingerprint (SHA-256 hash)
- letters you generate
- your profile (name, platforms) and settings (language)

There are no analytics and no advertising. Unless you turn on cloud backup (below), nothing
you record is stored anywhere but your phone.

## When data leaves your phone

Data leaves your phone only in these cases:

1. **Reading screenshots.** When you import a screenshot, the image is sent to Google's Gemini
   API to pull out the order or payout details. It passes through AsliKamai's server
   (a Supabase function in Mumbai, India), which forwards it to Gemini and does not store it.
   Google processes it under the [Gemini API terms](https://ai.google.dev/gemini-api/terms).
   AsliKamai does not send it anywhere else.
2. **Voice entry.** When you use the microphone for an expense, your phone's speech-recognition
   service (usually Google's) turns your voice into text. The app keeps only that text, never
   the audio.
3. **Fonts.** The first time the app runs, it downloads its fonts from Google Fonts. That
   download includes no personal data.
4. **Things you choose to share.** Exporting your data, sharing an earnings card, or sharing a
   letter or evidence item hands the file to the app you pick, such as WhatsApp, Gmail or
   Files. What happens after that is up to you and that app.

## Optional cloud backup

If you sign in with Google under More → Cloud backup, AsliKamai backs up your evidence photos,
generated letters and profile (name, platforms) so you can get them back on a new phone.

- **Where:** Supabase Storage in Mumbai, India, encrypted at rest.
- **Who can see it:** only your signed-in account. Access rules stop any other user from
  reading, listing or changing your backup. The developers can technically reach it through
  the Supabase admin console, and will only do so if you ask for help with your backup.
- **Earnings stay off by default.** Orders, expenses and order screenshots are included only if
  you switch on "Also back up orders & expenses".
- **Account data:** your Google account's email address and a user ID, used only to sign you
  in.
- **Turning it off** stops all syncing immediately, and you can choose to delete the cloud
  copy at the same time. "Delete cloud backup" deletes it at any time.
- **Delete everything** also deletes your cloud backup and your account.

## Permissions

- **Photos:** AsliKamai uses Android's Photo Picker, so it sees only the images you pick. It
  never gets access to your whole gallery.
- **Microphone:** used only while voice entry is listening.
- **Internet:** used for screenshot reading, font downloads and (if you turn it on) cloud
  backup, as described above.

## Your control

- **Export everything** (More → Export everything) saves all your data as a file.
- **Delete everything** (More → Delete everything) permanently erases all your data from the
  app, plus your cloud backup and account if you use backup. Uninstalling the app erases the
  data on your phone, but not a cloud backup; delete that from the app first, or email us.

## Children

AsliKamai is meant for working adults and is not directed at children under 18.

## Changes

If a future version adds pooled pay statistics, this policy will be updated first. That
feature will be opt-in, and any pooled data will be anonymous.

## Contact

Questions: ksethia1978@gmail.com
