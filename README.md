# Cryostat

One cooling clock for a shelf of wants. File several things you might buy. Only the active want loses a minute. Shelved wants stay frozen at the hours they already have.

## Why a queue fold

The product is not a list of timers. It is a queue with three states: Empty, Ticking, and Cool. The bento is that fold over wants.

- File on an empty queue seats the want as Active and folds to Ticking. File while the queue exists only adds a Shelved want.
- Swap writes a SwapMark and moves Active onto the tapped shelved want without resetting hours on either want.
- Donate writes a DonateMark when the shelved remaining hours cover the active shortfall, subtracts that shortfall, removes the shelved want, and folds to Cool. A short cover writes a ShortMark and keeps both wants.
- While Ticking, each minute subtracts one minute from the Active want and folds to Cool at zero.
- Release writes a ReleaseMark only from Cool. The next shelved want becomes Active with its stored hours. An empty bento writes Empty.
- Peel drops the last SwapMark or DonateMark and restores the prior Active, including hours a donation removed.

That fold is why a shopper can keep a wishlist without a wall of parallel clocks, and why buying early means giving up another want rather than checking out.

## Single-tick swap

Home is the mechanic. The wide tile is the only clock. Tap a frozen tile to swap the tick. The opening seed has one active want and a longer shelved want so the first tap is Swap. Donate, Release, and Peel stay on the same bento. Review, Rules, and Settings are sheets.

## Assets

Art direction: abstract cyberpunk digital art. Hard geometric shards, circuit traces, and one luminous focal mass in a void. Crisp digital painting with grain and a shallow glow. No lettering, no logos, no photographic people.

Image sets are named for a later generate step. Prompts:

- `cst_AppIcon`: Abstract cyberpunk emblem of a sealed cryogenic chamber, solid geometric mass filling the canvas edge to edge, no text, no letters, no rounded mask.
- `cst_Splash`: Vertical abstract cyberpunk field of circuit shards with a quiet uncluttered center band, filling the canvas, no text.
- `cst_Onboarding1`: Cutout of a sealed cryogenic canister, solid opaque body centered, transparent surroundings, no text.
- `cst_Onboarding2`: Cutout of a hand moving one solid tile onto another, opaque forms centered, transparent surroundings, no text.
- `cst_Onboarding3`: Cutout of an opened canister revealing a solid kept object, opaque subject centered, transparent surroundings, no text.
- `cst_EmptyHome`: Solid closed canister of ceramic and metal, fully opaque, centered, transparent corners, closed center, no text.
- `cst_EmptyList`: Solid empty bracket shelf, opaque subject centered, transparent surroundings, no text.
- `cst_CardBackdrop`: Abstract cyberpunk texture filling the whole canvas, low detail so type can sit on it, no text, quiet center.
- `cst_ControlFace`: Solid filled ring bezel with a closed center disc, opaque, centered, transparent corners, no text.
- `cst_TwistHero`: Solid emblem of one large ticking tile beside two smaller frozen tiles, opaque subject centered, transparent surroundings, no text.
- `cst_SuccessMark`: Solid filled metal seal occupying the middle of the canvas, opaque, transparent corners, thick closed form, no text.
- `cst_HeaderDecor`: Wide solid circuit ornament band, opaque motif, transparent field outside the band, no text.
