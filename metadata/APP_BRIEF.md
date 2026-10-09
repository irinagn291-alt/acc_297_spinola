<!-- gf-brief source=26f5d1ad15d4c7e3495c6a70478de00cdda904793471cddd6dadfc38571d414d written=2026-10-09T14:39:04+03:00 -->
# Spinola

## What it is

Spinola is a wait clock for people who have several things they might buy and do not want every timer running at once. You file possible buys; only one clock cools while the rest stay frozen. When the cooling ring reads zero you mark that buy as bought, or you donate frozen hours from another tile to finish sooner.

## Launch and onboarding

Cold launch is a system-generated dark launch screen with no wordmark, then either the three-page intro or Home. Dark appearance is fixed.

If the intro has not been finished, three full pages appear. Each page has a full-width primary button and a full-width **"Skip"**. **"Skip"** on any page leaves the intro, keeps the default monthly limit of 2000 (grouped for the device locale, for example **"2,000"**), sets Need to 40 and Discount to 20, and opens Home.

1. Illustration. Title **"One clock cools at a time"**. Body **"File the things you might buy. Only one clock runs. The rest stay frozen until you swap the tick."** Primary button **"Next"**.
2. Illustration. Title **"Swap the tick"**. Body **"Tap a frozen tile to move the clock. Stored hours on both tiles stay as they are."** Primary button **"Next"**.
3. Illustration. Title **"Your monthly limit"**. Field **"Monthly limit"** (number pad), prefilled with the locale-formatted default 2000. Slider labeled **"Need "** plus a whole number (starts at **"Need 40"**), range 0–100. Slider labeled **"Discount "** plus a whole number (starts at **"Discount 20"**), range 0–100. Keyboard accessory **"Done"**. Primary button **"Continue"**.

If **"Continue"** is tapped with a monthly limit that is missing or not above zero, the line **"Enter a monthly limit above zero, or skip to keep the default."** stays on this page. A valid **"Continue"** saves that limit plus the Need and Discount values and opens Home.

A later launch that already finished the intro goes straight to Home.

## Screens

There is no tab bar. Home stays up. Review, Rules, Settings, File a buy, Donate hours, Release, Swap, and Single tick arrive as sheets with a title and **"Close"**.

### Home

No navigation title. Decorative header art. Headline **"One clock is cooling"**. Line **"Tap a frozen tile to swap the tick."** Icon **"Rules"** opens Rules. Icon **"Settings"** opens Settings. A faint particle field sits behind the tiles (a still wash if Reduce Motion is on).

When nothing is cooling: illustration, **"Nothing is cooling"**, **"File a buy. The span starts."**, button **"File"** (opens File a buy).

If the shelf cannot be shown: **"The shelf could not be read"**, a reason line (the last note, or **"Start again from an empty bento."**), button **"File a buy"**.

When a buy is cooling, the wide tile is labeled **"Cooling now"** (or **"Ready to release"** when remaining hours are zero). It shows the buy name, the price in the chosen currency, remaining hours as a number plus **" h"**, a ring, and **"Long press to donate frozen hours."** Tap while still cooling opens Donate hours. Tap when ready opens Release. A long press lists **"Donate "** plus each frozen name and donates those hours at once.

Frozen tiles sit under the wide tile, two across. Each shows **"Frozen"**, the name, remaining hours plus **" h"**, and **"Swap the tick"**. Tap swaps the cooling tick onto that tile. Stored hours on both tiles stay as they are. A swap writes a mark.

A note banner can appear above the tiles (faults listed under Behaviours).

**"Marks"** row: caption **"Marks"** and either **"Swap writes the first mark."** or a count plus **" marks on the timeline."** (including **"1 marks on the timeline."**). Tap opens Review.

Timer icon **"Single tick"** opens Single tick.

When the ring reads zero, a full-width **"Release"** appears and immediately marks the cooling buy as bought. After that, the first frozen tile (if any) becomes the cooling tile with the hours it already stored. If the shelf is empty, Home returns to **"Nothing is cooling"**.

**"File"** always opens File a buy. A later file joins the frozen tiles; only the first file on an empty bento becomes the cooling tile.

**"Donate"** opens Donate hours. It is dimmed when there is no frozen tile, when the ring already reads zero, or while a write is running.

**"Peel"** restores the previous cooling tile after the latest swap or donate (including hours a donate removed). It is dimmed until a swap or donate has been written, or while a write is running.

A brief success seal can flash after a successful file, swap, covered donate, release, or peel. Controls fade while a write is running.

### File a buy

Title **"File a buy"**. **"Close"** dismisses.

Section **"Buy"**: field **"Name"**, field **"Price"** (decimal pad; the decimal separator follows the device locale). Keyboard **"Done"**.

Section **"Span"**: sliders **"Priority "** (1, 2, or 3), **"Need "** (0–100), **"Discount "** (0–100). Need and Discount start at the Rules defaults. Footer **"Hours come from the price against your monthly limit."** until Price is a number above zero, then **"This buy would cool for "** plus hours plus **" h."** Raising Priority lengthens that span. Raising Need or Discount shortens it. A very small price still previews **6 h**. A very large price previews **720 h**.

**"File"** is dimmed until **"Name"** has a non-space character (and while a write is running). On success the sheet closes and Home shows the new tile. Faults stay on this sheet (see Behaviours).

### Donate hours

Title **"Donate hours"**. **"Close"** dismisses.

Opened from **"Donate"**, from a tap on the cooling tile while it is still cooling, or from the long-press list.

If nothing is frozen: **"Nothing frozen to give"**, **"File another buy, then donate its hours toward release."**, **"Close"**.

Otherwise a line **"«name» still needs «hours» h."**, then a row per frozen tile **"Donate «name»"** with that tile’s hours. Footer **"A short gift stays on the shelf and writes a short mark."**

Tap a row. If those frozen hours cover what the cooling tile still needs, that frozen tile is removed in full (leftover hours on it are not kept), the cooling ring goes to zero, a donate mark is written, and the sheet closes. If they do not cover it, both tiles stay, a short mark is written, the sheet closes, and Home shows **"Those frozen hours do not cover the active ring. Both tiles stayed."**

### Release

Title **"Release"**. **"Close"** dismisses.

Reached by tapping the wide tile when it reads **"Ready to release"**.

Shows **"Ready to release"** or **"Still cooling"**, the name, remaining hours plus **" h"**, and either **"The ring reads zero. Release marks this buy as bought."** or **"Release stays closed until the ring reads zero. Swap a frozen tile, or wait."**

**"Release"** is dimmed until the ring reads zero (and while a write is running). A successful release matches the Home **"Release"** button.

If nothing is cooling, this sheet shows the same empty Home copy and **"File"**. If release did not run: **"Release did not run"**, the reason, **"Close"**.

### Swap

Title **"Swap"**. **"Close"** dismisses.

This is the list form of the same swap as tapping a frozen tile on Home. If nothing is cooling, it shows the empty Home copy and **"File"**. If nothing is frozen: **"Nothing is frozen"**, **"File another buy. Then tap it to move the tick."**, **"File"**.

Otherwise: caption **"Cooling now"**, the cooling name, remaining hours plus **" h"**, then **"Tap a frozen row. Both spans stay as they are."** Each row shows **"Frozen"**, the name, and remaining hours plus **" h"**. Tap swaps the tick onto that tile.

### Single tick

Title **"Single tick"**. **"Close"** dismisses.

Illustration. **"One tick"**. **"Only the active tile loses a minute. Frozen tiles keep the hours they already stored. Swap moves the tick. It does not restart either span."**

If a buy is cooling: caption **"Active"**, the name, remaining hours plus **" h"**. If not: **"Nothing is cooling"**. Frozen names and hours are listed below.

**"Back to the bento"** dismisses.

### Review

Title **"Review"**. **"Close"** dismisses. Opened from **"Marks"**.

Empty: illustration, **"No marks yet"**, **"Swap, donate, or release a buy and the timeline fills in."**, **"File"** (opens File a buy).

Failed: **"The timeline could not be read"**, a reason (or **"The marks will return when the chart loads."**), **"Close"**.

Filled: rows are ordered as they were written. Each row has a title, a detail, and a medium-style date (device locale and calendar, no time).

- **"Swap"** — **"Tick moved from «name» to «name»."** A name that can no longer be found reads **"Buy"**.
- **"Donate"** — **"«name» gave «hours» h."**
- **"Release"** — **"«name» was marked bought."**
- **"Short"** — **"Covered «hours» h of «hours» h. Both tiles stayed."**

Filing a buy does not add a row. Only swap, donate, release, and a short gift do.

### Rules

Title **"Rules"**. **"Close"** dismisses. Opened from the Rules icon.

Empty (no monthly limit yet): **"Set a monthly limit"**, **"Hours are priced against what you can spend in a month."**, **"Use 2,000"** (same locale grouping as the default 2000). That action saves 2000 and closes.

Failed: **"Rules could not load"**, a reason (or **"The last saved limit is still on the device."**), **"Close"**.

Ready: section **"Limit"**, field **"Monthly limit"**, footer **"New buys use this limit. Hours already stored stay put."** Sliders **"Default need "** and **"Default discount "** (0–100). Keyboard **"Done"**. **"Save"** writes the limit and the two defaults, then closes. Those defaults fill Need and Discount the next time you File a buy.

### Settings

Title **"Settings"**. **"Close"** dismisses. Opened from the Settings icon.

Empty currency: **"Pick a currency"**, **"Prices on the bento use this code."**, **"Use USD"**.

Failed: **"Settings could not load"**, a reason (or **"Try again after the chart recovers."**), **"Close"**.

Ready:

- Picker **"Currency"**: **"USD"**, **"EUR"**, **"GBP"**, **"JPY"**. Changing it saves at once. Prices on the cooling tile use this code.
- **"Contact"** opens the support page.
- **"Show the intro again"** closes Settings and returns to the three intro pages. Existing buys stay. The intro fields start at the defaults (2000, Need 40, Discount 20), not at the last saved Rules values. **"Skip"** or **"Continue"** overwrites the monthly limit and the Need / Discount defaults (currency is kept), then returns to Home.
- **"Reset the shelf"** asks **"Reset the shelf?"** with **"Buys and marks on this device are removed."** Buttons **"Reset the shelf"** and **"Cancel"**. Confirming removes buys and marks and returns you to the intro.

## Features

- File a buy with a name, a price, Priority, Need, and Discount
- A cooling span in hours, from the price against the monthly limit and those sliders
- One clock cooling at a time
- Frozen tiles that keep the hours they already stored
- Swap the tick by tapping a frozen tile
- Donate frozen hours toward release
- A short gift that stays on the shelf and writes a short mark
- Release when the ring reads zero, which marks that buy as bought
- Peel to restore the previous cooling tile after the latest swap or donate
- Marks timeline (Swap, Donate, Release, Short)
- Monthly limit, default Need, and default Discount in Rules
- Currency on the bento: USD, EUR, GBP, or JPY
- Single tick explainer
- Show the intro again
- Reset the shelf
- Contact

## Behaviours that can look like bugs

- **"File"** on File a buy stays dim until **"Name"** has a real character. Type a name.
- **"File"** with a missing or non-positive price stays on the sheet with **"Enter a price above zero so the span can be computed."** Typing a non-positive Price shows **"Use a number above zero."**
- A buy that cannot be filed can show **"That needs a name and a price the monthly limit can span."** or **"That buy could not be filed. Try a name and a price above zero."** Fix the name and a price above zero, and keep a monthly limit above zero in Rules.
- **"Continue"** on the last intro page refuses a limit that is not above zero: **"Enter a monthly limit above zero, or skip to keep the default."** Enter a positive limit or tap **"Skip"**.
- Rules **"Save"** refuses the same way: **"Enter a monthly limit above zero."**
- **"Skip"** on page 1 or 2 does not go to the next page. It ends the intro with the defaults.
- **"Show the intro again"** then **"Skip"** or **"Continue"** can replace a custom monthly limit with 2000 and reset Need / Discount defaults. Existing tiles keep the hours they already stored.
- The first **"File"** on an empty bento becomes the cooling tile. Later files only appear as **"Frozen"**. That is intended.
- Filing a buy does not change **"Marks"**. It still says **"Swap writes the first mark."** until you swap, donate, release, or give a short gift.
- Only the cooling tile loses time, one minute at a time, and only while the app stays open. Leaving the app pauses that clock; hours do not jump forward when you return. Frozen hours do not move. A swap does not restart either span.
- **"Release"** is hidden until remaining hours are **"0 h"**. On the Release sheet the button stays dim with **"Release stays closed until the ring reads zero. Swap a frozen tile, or wait."** Wait, donate enough hours, or swap to a tile that is already at zero. Refusals: **"Release only when the active ring reads zero."** / **"Release waits until the active ring reads zero."**
- After **"Release"**, you do not pick the next cooling tile. The first frozen tile on the shelf starts cooling with the hours it already stored. Swap if you want a different one.
- **"Donate"** on Home is dim when there are no frozen tiles or when the tile already reads **"Ready to release"**. File another buy first, or use **"Release"**. A tap on the cooling tile with nothing frozen opens **"Nothing frozen to give"**.
- Donate while the ring is already at zero is refused: **"Donate runs while a clock is still cooling."** A long-press **"Donate «name»"** on a tile that already reads **"Ready to release"** can show that line.
- A donate that is too small does not remove either tile. Home shows **"Those frozen hours do not cover the active ring. Both tiles stayed."** Review gains a **"Short"** row. File a larger frozen buy, or wait.
- A donate that is large enough removes the whole frozen tile even if it had hours left over. Those leftover hours are not kept. That is intended.
- **"Peel"** is dim until you have swapped or donated. Taps before that can show **"Nothing to peel. Swap or donate first."** / **"No swap or donate to peel."**
- Peel only undoes the latest swap or donate. After a later swap, donate, or release, **"Peel can only restore the latest swap or donate."**
- Release is not something Peel can undo. After **"Release"**, that buy stays marked bought.
- **"Swap the tick"** on a tile that is no longer frozen can show **"That tile is not frozen on the shelf."** or **"The tick stayed where it was. Tap a frozen tile again."**
- Actions while nothing is cooling can show **"Nothing is cooling yet. File a buy first."**
- The span preview can sit at **6 h** or **720 h** even when the price looks smaller or larger. That is the span the clock will use.
- After **"Release"** of the last tile, Home is again **"Nothing is cooling"**. File another buy.
- While a write is running, File, Donate, Peel, Release, and tiles fade and ignore extra taps. Wait a moment.
- A load problem can show **"The saved chart was unreadable. The last good copy is back."** or **"The saved chart was unreadable. Starting from an empty shelf."** on Home or in a sheet note. File again if the shelf is empty.
- A save problem can show **"The chart file could not be saved. The in-memory shelf is unchanged."** or **"The chart could not be encoded."** The tiles already on screen stay. Keep going, or reset if the shelf is empty.
- **"Reset the shelf"** needs the confirmation **"Reset the shelf?"**. **"Cancel"** leaves everything in place. A failed wipe can show **"Reset could not remove the chart file."** or **"Reset could not remove the chart backup."**

## Starter content and resume

None. Unfinished work resumes: filed buys, remaining hours, frozen tiles, marks, the monthly limit, Need / Discount defaults, currency, and whether the intro was finished all come back after quit and relaunch.

## Permissions

None.

## Absent

Login or accounts, in-app purchase, ads, analytics, user-generated content (no sharing or public posts; names you type stay on this device), account deletion flow, App Tracking Transparency prompt.

## Data and support

Buys, hours, marks, and rules stay on this device. **"Reset the shelf"** is the on-screen wipe; the confirm copy is **"Buys and marks on this device are removed."**

**"Contact"** in Settings opens the support page.

## Scanning and health

None.

## Platform

English copy only. Numbers, currency amounts, and mark dates follow the device locale and calendar. Currency is whichever of USD, EUR, GBP, or JPY you pick; there is no storefront or region lock.

Portrait only, full screen, on iPhone and iPad. Dark interface. Minimum iOS 17.0.

## Category

Finance.
