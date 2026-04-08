# Handover: Ebook Selection-Based Ask

## Goal

Implement ebook `Ask me` based on **selected text / selection-derived locator**, not the current automatic reading locator.

The current automatic locator is too coarse for spoiler-safe PoC behavior.

## Current Repo State

Main files:

- [ContentView.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/ContentView.swift)
- [Player/EbookReaderController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderController.swift)
- [Player/EbookReaderView.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderView.swift)
- [Player/EbookContentsSheet.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookContentsSheet.swift)
- [Player/AskConversationController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/AskConversationController.swift)
- [Models/EbookLocator.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/EbookLocator.swift)
- [Models/ReadtardAPIClient.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/ReadtardAPIClient.swift)
- [Models/ReadingProgressStore.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/ReadingProgressStore.swift)
- [README.md](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/README.md)

## What Currently Works

- Library opens first.
- Audiobook player works.
- EPUB opens in Readium.
- Ebook current position is persisted via `EbookLocator` JSON.
- `Ask me` from ebook sends a locator-based payload.
- Ask payload is printed to Xcode console before request in `AskConversationController.debugPrintRequest`.
- Full build succeeds.

## Current Ebook Ask Payload

Sent from [AskConversationController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/AskConversationController.swift) via [ReadtardAPIClient.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/ReadtardAPIClient.swift):

```json
{
  "book_id": "HarryPotter",
  "ebook": {
    "kind": "locator",
    "locator": {
      "fragments": [],
      "href": "index_split_000.html",
      "position": 2,
      "progression": 0.016260162601626018,
      "totalProgression": 0.0055248618784530384
    }
  },
  "question": "Test",
  "source": "ebook"
}
```

## Key Problem

Current ebook ask uses the **automatic current locator** from Readium:

- `position` is too coarse
- one `position` can span multiple visible ereader pages
- `progression` changes between visible pages even when `position` stays the same
- this makes automatic spoiler boundary weak for the PoC

Example observed manually:

- second ereader page and next ereader page both produced:
  - same `href`
  - same `position = 2`
  - different `progression`

So the automatic locator is not precise enough for the PoC.

## User Decision

For the PoC:

- do **not** spend more time perfecting automatic ebook position
- use **text selection** instead, if robust and easy
- ideally use a **selection-derived locator / CFI-like location**
- avoid changing backend/API more than necessary
- if possible, keep API conceptually as `ebook.kind = "locator"` and just make the locator more precise

## Important Discussion Outcome

User does **not** want:

- selection text only, because it may not be unique enough
- big API/backend churn unless necessary

Preferred approach:

- user selects text in the ebook
- frontend derives a precise location from that selection
- send a precise locator based on selection
- adjust the debug payload print accordingly

## What Was Not Completed

I started investigating Readium’s selection APIs but did not finish.

I attempted:

- `ExecuteSnippet` probing for delegate APIs
- local package grep via shell, but that command was rejected and then the turn was interrupted

So the next chat should start by finding the actual Readium selection hooks cleanly.

## What To Do Next

1. Inspect Readium Swift toolkit selection APIs.
   Goal:
   - determine how selected text is exposed
   - determine whether Readium provides a selection locator / CFI / range-like object

2. Implement selection state in ebook reader.
   Likely place:
   - [Player/EbookReaderController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderController.swift)

   Need:
   - selected locator
   - maybe selected text if available for debug only
   - expose whether a selection exists

3. Change ebook ask flow.
   Current:
   - ask uses `ebookReader.currentEbookLocator`

   Desired:
   - ask uses `selectedEbookLocator`
   - if nothing selected, either disable Ask or show message like:
     - `Select text before asking`

4. Update console payload debug print.
   It is already in:
   - [AskConversationController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/AskConversationController.swift)

   Need only to ensure it prints the **selection-derived locator**.

5. Keep automatic resume unchanged.
   Important distinction:
   - resume can still use automatic current locator
   - ask should use selected locator

## Current Simplified Ebook Controller

[EbookReaderController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderController.swift) was recently simplified:

- removed webview pagination measurement logic
- removed mixed TOC link/fragment/webview fallback complexity
- chapter jump now uses one path:
  - TOC entry -> resolved position locator -> rebuild navigator at that locator
- ebook resume now uses only persisted locator JSON, not page fallback

## Chapter Nav Status

Still user-reported unreliable in the live app, despite local validation that:

- Harry Potter NCX TOC maps to positions `1, 11, 19, 29, 39, 57, ...`
- directly building a Readium navigator with position `57` opens at chapter 6 resource

So chapter navigation is still not fully trusted in the real UI. But that is secondary to the new selection-based ask direction.

## Useful Files To Inspect First In Next Chat

- [Player/EbookReaderController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderController.swift)
- [Player/EbookReaderView.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/EbookReaderView.swift)
- [Player/AskConversationController.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Player/AskConversationController.swift)
- [Models/EbookLocator.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/EbookLocator.swift)
- [Models/ReadtardAPIClient.swift](/Users/daanbarsukoffponiatowsky/Projects/readtard-app/Readtard/Models/ReadtardAPIClient.swift)

## Best First Prompt For Next Chat

Use something like:

> Implement ebook ask based on Readium text selection instead of the current automatic locator. I want the selected passage to produce a precise locator/CFI-like location if Readium supports it, and I want `Ask me` to send that selection-derived locator. Keep API/backend changes minimal. Also update the debug payload print so I can inspect the selection-based payload in Xcode console.
