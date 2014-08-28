"=============================================================================
" FILE: autoload/eew/epsp.vim
" AUTHOR: haya14busa
" Last Change: 28-08-2014.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Ref: http://p2pquake.ddo.jp/p2pquake/EPSP/partA_010.html

let s:TRUE  = !0
let s:FALSE = !!0
let g:eew#epsp#debug = get(g:, 'eew#epsp#debug', s:FALSE)

let s:base_url = 'http://api.p2pquake.net/userquake'
let s:HTTP = eew#http()

function! eew#epsp#fetch()
    let date = strftime('%m/%d')
    let url = s:base_url . '?date=' . date
    let request = s:HTTP.get(url)
    let split_data = filter(map(split(iconv(request.content, 'shift-jis', &encoding), '\n'), "
    \   split(substitute(v:val, '\r', '', ''), ',')
    \ "), 'v:val[1] ==# ''QUA''')
    " select only code ==# 'QUA'

    " Make dictionary of detail information
    let infos = map(copy(split_data), "split(v:val[2], '/')")
    let infos = map(infos, "
    \   {
    \       'date' : v:val[0]
    \     , 'intensity' : v:val[1]
    \     , 'has_tsunami' : v:val[2]
    \     , 'info_type' : v:val[3]
    \     , 'focus' : v:val[4]
    \     , 'depth' : v:val[5]
    \     , 'magnitude' : v:val[6]
    \     , 'has_correction' : v:val[7]
    \     , 'latitude' : v:val[8]
    \     , 'longitude' : v:val[9]
    \   }
    \ ")

    let result = map(split_data, "
    \   {
    \    'time': v:val[0],
    \    'code': v:val[1],
    \    'info': infos[index(split_data, v:val)]
    \   }
    \ ")
    return result
endfunction

function! eew#epsp#prefetch()
    let s:prev_data = eew#epsp#fetch()
endfunction
call eew#epsp#prefetch()

function! eew#epsp#notify()
    let new_data = eew#epsp#fetch()

    if (exists('s:prev_data') && s:prev_data != new_data) || g:eew#epsp#debug == s:TRUE
        let e = new_data[0].info
        echom printf('地震速報: %s頃, %sで震度%sの地震が発生しました'
        \            , e.date, e.focus, e.intensity)
    endif

    let s:prev_data = new_data
endfunction


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
