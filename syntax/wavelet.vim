if exists("b:current_syntax")
  finish
endif

syntax case match

syntax match waveletPunctuation "[(){}\[\],:/]"

syntax match waveletNumber "-\?\<\%(inf\|nan\|\d\+\%(\.\d\+\)\?\%([eE][+-]\?\d\+\)\?\)\>"

syntax keyword waveletBoolean true false
syntax keyword waveletConstant some none ok err

syntax match waveletPlaceholder "\%([A-Za-z0-9_-]\)\@<!_\%([A-Za-z0-9_-]\)\@!"

syntax match waveletCallHead "%\?[A-Za-z][A-Za-z0-9_-]*\%(/%\?[A-Za-z0-9_-]\+\)*\%((\)\@="


syntax match waveletProperty "%\?[A-Za-z][A-Za-z0-9_-]*\%(\s*:\)\@="

syntax match waveletMacro "\<\%([A-Za-z][A-Za-z0-9]*[-/]\)*[A-Z][A-Za-z0-9]*[a-z][A-Za-z0-9]*\%([-/][A-Za-z][A-Za-z0-9]*\)*\>"

syntax match waveletChar "'\%(\\\%(u{[0-9a-fA-F]\+}\|.\)\|[^\\']\)'"

syntax match waveletEscape contained "\\\%(u{[0-9a-fA-F]\+}\|[nrt\\\"']\)"
syntax region waveletString start=+"+ skip=+\\"+ end=+"+ contains=waveletEscape

syntax match waveletComment "//.*$"

syntax match waveletShebang "\%^#!.*$"

highlight default link waveletShebang     Comment
highlight default link waveletComment     Comment
highlight default link waveletString      String
highlight default link waveletEscape      SpecialChar
highlight default link waveletChar        Character
highlight default link waveletNumber      Number
highlight default link waveletBoolean     Boolean
highlight default link waveletConstant    Constant
highlight default link waveletPlaceholder Constant
highlight default link waveletMacro       Keyword
highlight default link waveletCallHead    Function
highlight default link waveletProperty    Label
highlight default link waveletPunctuation Delimiter

let b:current_syntax = "wavelet"
