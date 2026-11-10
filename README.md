# MyXPBar Played Time

A World of Warcraft addon for [MyXPBar Forever](https://www.curseforge.com/wow/addons/myxpbar-forever). It shows how long you have been on your current level and your total time played, right next to the level on the XP bar:

`Level 35 (2h 45m · total 2d 6h)`

- **Time at this level and total time played** on the bar, updated every second, no need to type `/played`
- **No chat spam:** the addon asks the server for your played time once at login without the chat message, and only if no other addon already did
- **Starts over on level up:** the time at the level goes back to zero when you ding
- **Fits the bar:** follows the level text of MyXPBar, in every bar style, and hides with it (e.g. when the bar shows your reputation only)
- **Leaves MyXPBar untouched:** a separate addon, so MyXPBar updates as usual
- Available in all languages of the WoW Forever client

## Supported game versions

| Version | Interface |
|---|---|
| WoW Forever | 16001 |

Classic Era and other versions are not supported. Requires [MyXPBar Forever](https://www.curseforge.com/wow/addons/myxpbar-forever).

## Installation

Install it from [CurseForge](https://www.curseforge.com/wow/addons/myxpbar-played-time), e.g. with the CurseForge app.

For a manual installation, note that the folder in your AddOns directory **must** be named `MyXPBarPlayedTime`, otherwise WoW will not load the addon:

```bash
cd "C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns"
git clone https://github.com/byWulf/wow-myxpbar-played-time.git MyXPBarPlayedTime
```

Alternatively, download the ZIP from the [releases](https://github.com/byWulf/wow-myxpbar-played-time/releases) and extract it into `Interface/AddOns`.

Then `/reload` in game.

## Usage

Nothing to set up. Once the addon is enabled, the times appear next to the level on MyXPBar a few seconds after login. Typing `/played` syncs them with the server again.

## Languages

All languages of the WoW Forever client: English, German, French, Spanish (EU and Latin America), Brazilian Portuguese, Russian, Korean, Simplified and Traditional Chinese. The language follows your WoW client.

## License

MIT, see [LICENSE](LICENSE).
