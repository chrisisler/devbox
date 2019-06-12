" call clearmatches()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" keyword: this
" highlight javascriptIdentifier ctermfg=3 cterm=italic
highlight javascriptFuncArg ctermfg=6 cterm=italic

highlight javascriptIdentifierName ctermfg=9

highlight xmlTag ctermfg=7
" JSX prop names
highlight xmlAttrib ctermfg=11 cterm=italic

" let, const
highlight javascriptVariable ctermfg=magenta

" await
highlight javascriptAwaitFuncKeyword ctermfg=magenta
" async
call matchadd("javascriptAwaitFuncKeyword", '\<async\>\ze\s\+')

" class
highlight javascriptClassKeyword ctermfg=magenta
" try
highlight javascriptTry ctermfg=magenta
" highlight javascriptArrowFunc ctermfg=magenta

" keywords: default, export
highlight javascriptExport ctermfg=darkmagenta cterm=italic
highlight javascriptClassExtends ctermfg=magenta cterm=italic
highlight javascriptImport ctermfg=darkmagenta


highlight javascriptReturn ctermfg=magenta cterm=italic,underline
call matchadd("javascriptReturn", '\<throw\>\ze\s\+')

" object keys (not es6 key/val sorthand)
highlight javaScriptObjectLabel ctermfg=darkmagenta

highlight javascriptTypeHintOnly ctermfg=11

" highlight javascriptComma ctermfg=cyan
" spread/rest operator
" highlight javascriptObjectLiteral ctermfg=cyan


" NOTE: These dont work
" highlight javascriptCase ctermfg=magenta cterm=italic
" highlight javascriptFuncKeyword ctermfg=magenta cterm=italic
" highlight javascriptObjectLabelColon ctermfg=cyan
" highlight javascriptEndColons ctermfg=cyan
" highlight javascriptCatch ctermfg=magenta cterm=italic
" highlight javaScriptObjectLabel ctermfg=green
" highlight javaScriptReserved ctermfg=green
" highlight javascriptPropertyName ctermfg=green cterm=italic
" highlight javascriptProp ctermfg=green cterm=italic
" highlight javascriptProps ctermfg=green cterm=italic
" highlight javascriptProperty ctermfg=green cterm=italic

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" highlight BraceSyntax ctermfg=darkmagenta
" call matchadd("BraceSyntax", '{')
" call matchadd("BraceSyntax", '}')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" if else
highlight Conditional ctermfg=magenta


" for, while, do, of
highlight Repeat ctermfg=magenta


" try, catch
highlight Exception ctermfg=magenta


" case, default
" highlight Label cterm=italic ctermfg=magenta

" instanceof, typeof, new, in, void
highlight Identifier ctermfg=magenta


highlight Magenta ctermfg=magenta
call matchadd("Magenta", '\<finally\>')
call matchadd("Magenta", '\<catch\>\ze\s\+(')
call matchadd("Magenta", '\<static\>\ze\s\+')
call matchadd("Magenta", '\<delete\>\ze\s\+')
call matchadd("Magenta", '\<get\>\ze\s\+')
call matchadd("Magenta", '\<set\>\ze\s\+')
call matchadd("Magenta", '\<type\>\ze\s\+')
call matchadd("Magenta", '\<yield\>\ze')
call matchadd("Magenta", '\s\+=>\s*')


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


highlight Red ctermfg=red
call matchadd("Red", '\<\h\w*\>\.\<\h\w*\>\.\zs\<\h\w*\>')
call matchadd("Red", '\(\<\h\w*\>\.\)\+\zs\<\h\w*\>')
" call matchadd("Red", '[^.]\.\zs\<\h\w*\>')
call matchadd("Red", '\<\h\w*\>\.\zs\<\h\w*\>')
" For properties of objects retrieved by index.
call matchadd("Red", ']\.\zs\<\h\w*\>')


" highlight Bananas ctermfg=blue
" let parens = '[()]'
" call matchadd("Bananas", parens)
" highlight javascriptBraces ctermfg=10


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

highlight FunctionSyntax ctermfg=darkblue

" function call
call matchadd("FunctionSyntax", '\<\h\w*\>\ze(')
" flow function support with generics
" call matchadd("FunctionSyntax", '\<\h\w*\>\ze<.*>(')

" function definition
call matchadd("FunctionSyntax", '\<\w\+\>\s\+\zs\<\h\w*\>\ze\s\+=[^{.<>]\+=>') 
" function definition as a method on something but not in an object instantiation
" example: Person.staticMethod = () => {}
" call matchadd("FunctionSyntax",        '.\+\.\zs\<\h\w*\>\ze\s\+=[^{.<>]\+=>') 
" call matchadd("FunctionSyntax",        '.\+\.\zs\<\h\w*\>\ze\s\+=[^{.<>]function') 

" function definition as an arrow method: `onClick = event => { ... }`
" call matchadd("FunctionSyntax", '\s\+\zs\<\h\w*\>\ze\s\+=[^{.<>]\+=>') 

" function definition with destructuring
call matchadd("FunctionSyntax", '\<\w\+\>\s\+\zs\<\h\w*\>\ze\s\+=\s\+(.*)\s\+=>')
" function definition with destructuring as a method on something but not in an object instantiation
" example: Person.staticMethod = () => {}
" call matchadd("FunctionSyntax",        '.\+\.\zs\<\h\w*\>\ze\s\+=\s\+(.*)\s\+=>')


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call matchadd("Magenta", '\<function\>\ze\s*.*(')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight Comments ctermfg=white
call matchadd("Comments", '^//\zs.*')
call matchadd("Comments", '\s\+//\zs.*')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" highlight link javascriptString javascriptTemplate

" Template string braces and '$' char
" highlight javascriptTemplateSB ctermfg=13
