# gb-sprite-hide
A library for the classic gameboy that lets you disable sprites on certain scanlines
## Setup
Set up your Stat interrupt handler to jp to `Stat`.

Call `spriteHideVBlank` in your VBlank handler (clobbers af de and hl).

Before enabling interrupts call `initSpriteHide`.
## Usage
You can call `InitBuffer` `AddSpriteToScanline` `NextScanline` `EndBuffer`
during your gameplay loop, when you're done call `SwitchBuffers` and the changes take effect next frame.
### Note: Always add scanlines in ascending order, calling NextScanline(5), NextScanline(2) would be illegal
## Examples
Disable sprite 1 and 5 in scanline 10, disable sprite 29 in scanline 55
```
ld b, 10
call InitBuffer
ld b, 0
call AddSpriteToScanline
ld b, 4
call AddSpriteToScanline
ld b, 55
call NextScanline
ld b, 28
call AddSpriteToScanline
call EndBuffer
call SwitchBuffers
```
Disable sprite hiding
```
ld b, $FF
call InitBuffer
call EndBuffer
call SwitchBuffers
```
## Limitations
Since we're cutting of sprites at a certain scanline they can't be partially occlueded behind a background tile.
So you need some clever masking for transitioning from hidden to not hidden.
