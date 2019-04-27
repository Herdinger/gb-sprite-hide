include "hw.asm"
section "spriteHide", rom0
initSpriteHide::
    ld a, 0
    ld [buffer1Current], a
    ld a, $c3 ;jmp instruction header
    ld [hblank_jmp], a
    call InitBuffer
    call SwitchBuffers
    ld hl, rIE
    set 1, [hl]
    ret

spriteHideVBlank::
    ld a, [buffer1Current]
    dec a
    ld de, buffer2
    jp nz, .bufferSet
    ld de, buffer1
.bufferSet:
    ld a,[de]
    cp $FF
    jp nz, .enable
    ld hl, rSTAT
    res 6, [hl]
    ret
.enable:
    ld [rLYC], a
    inc de
    ld hl, hblank_jmp + 1
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, rSTAT
    set 6, [hl]
    ret
section "stat", rom0

Stat::
    push hl; 4
    push af; 4
    ld hl, rSTAT; 3 is 0xFF41 afterwards
    bit 0, [hl] ;4
    jp NZ, .notHBlank ;4 if taken 3 if not
    bit 1, [hl] ;4
    jp Z, hblank_jmp ; 4 if taken 3 if not
.notHBlank:
    bit 2, [hl]
    jp Z, .end
    set 3, [hl] ;4 enable hblank
    res 6, [hl] ;disable lyc=ly
.end:
    pop af
    pop hl ; 3
    reti ; 4

StatEndNoNewline:
    inc h
    ld l, $41
    res 3, [hl]
    set 6, [hl]
    pop af
    pop hl
    reti


StatEnd:
    ;next code location is on top of stack :)
    ;bc got pushed and has next scanline in b
    ;hl 0xFE
    inc h
    ld l, $45
    ld [hl], b
    ld l, $41
    res 3, [hl]
    set 6, [hl]
    pop bc ;now code location in bc, old bc on stacktop
    ld hl, hblank_jmp + 1
    ld [hl], c
    inc hl
    ld [hl], b
    pop bc
    pop af
    pop hl
    reti

;inital scanline in b, trashes a, cand hl disable if b == 255
InitBuffer::
    ld a, [buffer1Current]
    dec a
    ld hl, buffer2
    jp z, .bufferSet
    ld hl, buffer1
.bufferSet
    ld a, b
    ld [hli], a; firstScanLineNumber
    ld a, $25 ; dec h
    ld [hli], a
    ld a, l
    ld [bufferIndex], a
    ld a, h
    ld [bufferIndex+1], a
    ret
; parameter in b
AddSpriteToScanline::
    ld hl, bufferIndex
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld [hl], $2e; ld, l
    inc hl
    sla b
    sla b
    ld [hl], b ; spriteNumber
    inc hl
    ld a, $74 ; ld [hl], h
    ld [hli], a
    ld a, l
    ld [bufferIndex], a
    ld a, h
    ld [bufferIndex+1], a
    ret

SwitchBuffers::
    ld a, [buffer1Current]
    xor a, 1
    ld [buffer1Current], a
    ret


NextScanline::
    ld hl, bufferIndex
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld [hl], $c5 ; push bc
    inc hl
    ld [hl], $06 ; ld b
    inc hl
    ld [hl], b ; scanline
    inc hl
    ld [hl], $CD ; call
    inc hl
    ld [hl], LOW(StatEnd)
    inc hl
    ld [hl], HIGH(StatEnd)
    inc hl
    ld a, $25 ; dec h
    ld [hli], a
    ld a, l
    ld [bufferIndex], a
    ld a, h
    ld [bufferIndex+1], a
    ret
EndBuffer::
    ld hl, bufferIndex
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld [hl], $c3 ; jp
    inc hl
    ld [hl], LOW(StatEndNoNewline)
    inc hl
    ld [hl], HIGH(StatEndNoNewline)
    inc hl
    ld a, l
    ld [bufferIndex], a
    ld a, h
    ld [bufferIndex+1], a
    ret

section "sprite buffers", wram0
bufferIndex: ds 2
SpriteBuffers:
buffer1: ds 300
buffer2: ds 300
SpriteBuffersEnd:

section "vars where hl is ff", hram

hblank_jmp:: ds 3
buffer1Current: ds 1




