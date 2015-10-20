" Clear augroup =========================================== {{{
augroup MyVimrc
    autocmd!
augroup END
" }}}

" Startup ================================================= {{{
if has('vim_starting')
    if !has('autocmd')
        echoerr "Recompile with +autocmd !"
        finish
    elseif !has('iconv')
        echoerr "Recompile with +iconv !"
        finish
    elseif !has('multi_byte')
        echoerr "Recompile with +multi_bute !"
        finish
    elseif !has('syntax')
        echoerr "Recompile with +syntax !"
        finish
    endif

    " http://rbtnn.hateblo.jp/entry/2014/11/30/174749
    if &encoding !=# 'utf-8'
        set encoding=japan
        set fileencoding=japan
    endif

    scriptencoding utf-8
    " ↑より前に日本語のコメントを書いてはいけない。
    " http://rbtnn.hateblo.jp/entry/2014/11/30/174749

    " Encoding : 文字コード自動判定 ========================== {{{
    " http://www.kawaz.jp/pukiwiki/?vim#cb691f26
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
        " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
    if &encoding ==# 'utf-8'
        let s:fileencodings_default = &fileencodings
        if has('mac')
            let &fileencodings = s:enc_jis .','. s:enc_euc
            let &fileencodings = &fileencodings .','. s:fileencodings_default
        else
            let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
            let &fileencodings = &fileencodings .','. s:fileencodings_default
        endif
        unlet s:fileencodings_default
    else
        let &fileencodings = &fileencodings .','. s:enc_jis
        set fileencodings&
        set fileencodings+=utf-8,ucs-2le,ucs-2
        if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
            set fileencodings+=cp932
            set fileencodings-=euc-jp
            set fileencodings-=euc-jisx0213
            set fileencodings-=eucjp-ms
            let &encoding = s:enc_euc
            let &fileencoding = s:enc_euc
        else
            let &fileencodings = &fileencodings .','. s:enc_euc
        endif
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis

    " 日本語を含まない場合はfileencodingにencodingを使うようにする
    function! AU_ReCheck_FENC()
        if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
            let &fileencoding=&encoding
        endif
    endfunction
    autocmd MyVimrc BufReadPost * call AU_ReCheck_FENC()

    " 改行コードの自動認識
    set fileformats=unix,dos,mac

    " □とか○の文字があってもカーソル位置がずれないようにする
    if exists('&ambiwidth')
        if has('macunix')
            set ambiwidth=single
        else
            set ambiwidth=double
        endif
    endif
    " }}}

endif
" }}}

" Functions =============================================== {{{
function! s:MkdirP(dir)
    if !isdirectory(a:dir)
        call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
endfunction
" }}}

" Directories & Runtimepath =============================== {{{
if has('vim_starting')
    let s:rc_dir = fnamemodify($MYVIMRC, ":p:h")

    " neobundle
    let s:bundle_dir    = s:rc_dir . '/bundle'
    let s:neobundle_dir = s:bundle_dir . '/neobundle.vim'
    let &runtimepath    = &runtimepath . ',' . s:neobundle_dir
    call s:MkdirP(s:neobundle_dir)

    " template
    call s:MkdirP(s:rc_dir . '/template')

    " runtimepath
    if executable('gocode') && exists('$GOPATH')
        let &runtimepath = &runtimepath . ',' . globpath($GOPATH, 'src/github.com/nsf/gocode/vim')
    endif
endif
" }}}

" NeoBundle : プラグイン {{{
" `loadplugins`がtrueならNeoBundleを実行する。
" `--noplugin`で起動してもNeoBundleでの設定が中途半端に読み込まれるので、
" `loadplugins`をチェックする。
if &loadplugins
    " https://github.com/Shougo/neobundle.vim
    " http://blog.supermomonga.com/articles/vim/neobundle-sugoibenri.html
    " http://qiita.com/rbtnn/items/39d9ba817329886e626b
    " http://vim-users.jp/2011/10/hack238/

    " neobundle.vimの有無をチェック。
    " neobundle.vimが無くてもgitコマンドが存在すれは
    " githubから持ってくる。
    if !filereadable(s:neobundle_dir . '/autoload/neobundle.vim')
        if (has('macunix') || has('unix') || has('win32unix')) && executable('git')
            " https://github.com/joedicastro/dotfiles/blob/master/vim/vimrc
            silent exe '!git clone https://github.com/Shougo/neobundle.vim '
             \  . s:neobundle_dir
        else
            echoerr "Install NeoBundle (neobundle.vim) plugin !"
            finish
        endif
    endif

    call neobundle#begin(s:bundle_dir)

    " neobundle.vimをneobundle自身で管理する。
    NeoBundleFetch 'Shougo/neobundle.vim'

    NeoBundle 'altercation/vim-colors-solarized'
    NeoBundle 'gcmt/wildfire.vim'
    NeoBundle 'itchyny/lightline.vim'
    NeoBundle 'thinca/vim-localrc', {'disabled':has('win32unix')}
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'vim-scripts/cecutil.git'

    NeoBundleLazy 'AndrewRadev/linediff.vim'
    NeoBundleLazy 'Lokaltog/vim-easymotion'
    NeoBundleLazy 'Shougo/context_filetype.vim'
    NeoBundleLazy 'Shougo/neocomplcache.vim'
    NeoBundleLazy 'Shougo/neomru.vim', {'depends':['Shougo/unite.vim']}
    NeoBundleLazy 'Shougo/neosnippet.vim', {
     \  'depends' : ['Shougo/neocomplcache.vim']}
    NeoBundleLazy 'Shougo/unite-outline', {'depends':['Shougo/unite.vim']}
    NeoBundleLazy 'Shougo/unite.vim', {'depends':['Shougo/vimproc']}
    NeoBundleLazy 'Shougo/vimproc', {
     \  'build' : {
     \      'cygwin'  : 'make -f make_cygwin.mak',
     \      'mac'     : 'make -f make_mac.mak',
     \      'unix'    : 'make -f make_unix.mak',
     \      'windows' : 'make -f make_mingw32.mak',
     \  }}
    NeoBundleLazy 'airblade/vim-gitgutter', {'vim_version':'7.3.105'}
    NeoBundleLazy 'airblade/vim-rooter'
    NeoBundleLazy 'c9s/perlomni.vim'
    NeoBundleLazy 'cohama/agit.vim'
    NeoBundleLazy 'eagletmt/ghcmod-vim', {
     \  'depends'           : ['Shougo/vimproc'],
     \  'external_commands' : ['ghc-mod'],
     \  }
    NeoBundleLazy 'ervandew/supertab'
    NeoBundleLazy 'h1mesuke/vim-alignta'
    NeoBundleLazy 'kana/vim-filetype-haskell'
    NeoBundleLazy 'kmnk/vim-unite-giti', {'depeneds':['Shougo/unite.vim']}
    NeoBundleLazy 'koron/codic-vim'
    NeoBundleLazy 'lambdalisue/vim-gista', {
     \  'depends'           : ['Shougo/unite.vim', 'tyru/open-browser.vim'],
     \  'external_commands' : ['curl'],
     \  }
    NeoBundleLazy 'mattn/perlvalidate-vim'
    NeoBundleLazy 'mojako/ref-sources.vim', {
     \  'depends'           : ['thinca/vim-ref'],
     \  'external_commands' : ['curl'],
     \  }
    NeoBundleLazy 'osyo-manga/vim-anzu'
    NeoBundleLazy 'osyo-manga/vim-precious'
    NeoBundleLazy 'othree/html5.vim'
    NeoBundleLazy 'rhysd/unite-codic.vim', {
     \  'depends':['Shougo/unite.vim', 'koron/codic-vim'],
     \  }
    NeoBundleLazy 'scrooloose/syntastic'
    NeoBundleLazy 'tacroe/unite-mark', {'depends':['Shougo/unite.vim']}
    NeoBundleLazy 'thinca/vim-quickrun', {'vim_version':'7.2'}
    NeoBundleLazy 'thinca/vim-ref'
    NeoBundleLazy 'tpope/vim-fugitive', {'external_commands':['git']}
    NeoBundleLazy 'ujihisa/neco-ghc', {'external_commands':['ghc-mod']}
    NeoBundleLazy 'ujihisa/ref-hoogle', {
     \  'depends'           : ['thinca/vim-ref'],
     \  'external_commands' : ['hoogle'],
     \  }
    NeoBundleLazy 'vim-jp/vim-go-extra', {
     \  'depends'           : ['Shougo/vimproc'],
     \  'external_commands' : ['go']
     \  }
    NeoBundleLazy 'vim-pandoc/vim-pandoc-syntax', {'vim_version':'7.4'}
    NeoBundleLazy 'vim-perl/vim-perl'

    call neobundle#end()

    " Required!
    filetype plugin indent on

    " Brief help
    " :NeoBundleList          - list configured bundles
    " :NeoBundleInstall(!)    - install(update) bundles
    " :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

    " 未インストールのplguinが存在する場合は
    " 自動でインストール。
    NeoBundleCheck

    " Installation check.
    if neobundle#exists_not_installed_bundles()
        echomsg 'Not installed bundles : ' .
         \ string(neobundle#get_not_installed_bundle_names())
        echomsg 'Please execute ":NeoBundleInstall" command.'
        finish
    endif

    " Plguin : Agit.vim ======================================= {{{
    " https://github.com/cohama/agit.vim
    if neobundle#tap('agit.vim')
        call neobundle#config({
         \ 'autoload': {
         \     'commands':['Agit', 'AgitFile'],
         \ }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : Cscope ========================================= {{{
    " http://cscope.sourceforge.net/
    " http://blog.miraclelinux.com/penguin/2007/02/vi_7fa6.html
    if has("cscope")
        set csprg=/usr/bin/cscope
        set csto=0
        set cst
        set nocsverb
        " add any database in current directory
        if filereadable("cscope.out")
            cs add cscope.out
            " else add database pointed to by environment
        elseif $CSCOPE_DB != ""
            cs add $CSCOPE_DB
        endif
        set csverb
        map g<C-]> :cs find 3 <C-R>=expand("<cword>")<CR><CR>
        map g<C-\> :cs find 0 <C-R>=expand("<cword>")<CR><CR>
    endif
    " }}}

    " Plugin : codic-vim ====================================== {{{
    " https://github.com/koron/codic-vim
    if neobundle#tap('codic-vim')
        call neobundle#config({
         \  'autoload': {
         \      'commands'  : ['Codic'],
         \      'on_source' : ['unite-codic.vim'],
         \  }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : ghcmod-vim ===================================== {{{
    " https://github.com/eagletmt/ghcmod-vim
    if neobundle#tap('ghcmod-vim')
        call neobundle#config({
         \  'autoload'  : {'filetypes' : ['haskell']},
         \  'on_source' : ['Shougo/vimproc'],
         \ })

        function! neobundle#tapped.hooks.on_source(bundel)
            let g:haddock_browser = "firefox"
            autocmd MyVimrc BufWritePost,FileWritePost *.hs :GhcModCheck
            autocmd MyVimrc FileType haskell nnoremap [ghcmod] <Nop>
            autocmd MyVimrc FileType haskell nmap     <Space>g [ghcmod]
            autocmd MyVimrc FileType haskell nnoremap <buffer> [ghcmod]c  :GhcModCheck<CR>
            autocmd MyVimrc FileType haskell nnoremap <buffer> [ghcmod]l  :GhcModLint<CR>
            autocmd MyVimrc FileType haskell nnoremap <buffer> [ghcmod]t  :GhcModTypeClear<CR>:GhcModType<CR>
            autocmd MyVimrc FileType haskell nnoremap <buffer> [ghcmod]tc :GhcModTypeClear<CR>
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : html5 ========================================== {{{
    if neobundle#tap('html5')
        call neobundle#config({
         \  'autoload': {'filetypes': ['html']},
         \ })

        call neobundle#untap()
    endif
    " }}}

    " Plugin : lightline.vim ================================== {{{
    " http://d.hatena.ne.jp/itchyny/20130828/1377653592
    " http://qiita.com/yuyuchu3333/items/20a0acfe7e0d0e167ccc
    " https://github.com/itchyny/lightline.vim
    if neobundle#tap('lightline.vim')
        let s:colorscheme
         \ = neobundle#is_installed('vim-colors-solarized')
         \ ? 'solarized'
         \ : 'wombat'
        let g:lightline = {
         \ 'colorscheme': s:colorscheme,
         \ 'mode_map': {'c': 'NORMAL'},
         \ 'active': {
         \   'left': [
         \     [ 'mode' ],
         \     [ 'fugitive', 'gitgutter', 'filename', 'anzu' ]
         \   ],
         \   'right': [
         \     [ 'syntastic', 'lineinfo' ],
         \     [ 'percent' ],
         \     [ 'charcode', 'fileformat', 'fileencoding', 'filetype' ]
         \   ],
         \ },
         \ 'component_expand': {
         \   'syntastic': 'SyntasticStatuslineFlag'
         \ },
         \ 'component_function': {
         \   'anzu'         : 'MyAnzu',
         \   'charcode'     : 'MyCharCode',
         \   'fileencoding' : 'MyFileencoding',
         \   'fileformat'   : 'MyFileformat',
         \   'filename'     : 'MyFilename',
         \   'filetype'     : 'MyFiletype',
         \   'fugitive'     : 'MyFugitive',
         \   'gitgutter'    : 'MyGitgutter',
         \   'lineinfo'     : 'MyLineinfo',
         \   'mode'         : 'MyMode',
         \   'percent'      : 'MyPercent',
         \ },
         \ 'component_type': {
         \   'syntastic': 'error'
         \ },
         \ 'separator': { 'left': '', 'right': '', },
         \ 'subseparator': { 'left': '', 'right': '', },
         \ }

        let s:funcorder = [
         \ 'MyMode'         , 'MyFilename' , 'MyLineinfo'   ,
         \ 'MyPercent'      , 'MyFugitive' , 'MyAnzu'       ,
         \ 'MyFileencoding' , 'MyFiletype' , 'MyFileformat' ,
         \ 'MyGitgutter'    , 'MyCharCode'     ,
         \ ]

        function! s:is_display(width, funcname)
            let l:index = index(s:funcorder, a:funcname)
            let l:width = a:width
            for i in range(l:index)
                let l:width += strlen(call(s:funcorder[i], [])) + 2
            endfor
            return winwidth(0) >= l:width ? 1 : 0
        endfunction

        " http://qiita.com/shiena/items/f53959d62085b7980cb5
        function! MyAnzu() " {{{
            if !neobundle#is_installed('vim-anzu')
                return ''
            endif
            let l:anzu = anzu#search_status()
            return s:is_display(strlen(l:anzu), 'MyAnzu') ? l:anzu : ''
        endfunction " }}}

        " カーソル下にある文字の文字コードを取得する。
        " http://qiita.com/yuyuchu3333/items/20a0acfe7e0d0e167ccc
        " https://github.com/Lokaltog/vim-powerline/blob/develop/autoload/Powerline/Functions.vim
        function! MyCharCode() " {{{
            " Get the output of :ascii
            redir => ascii
            silent! ascii
            redir END

            if match(ascii, 'NUL') != -1
                return s:is_display(strlen('NUL'), 'MyCharCode') ? 'NUL' : ''
            endif

            " Get the character and the numeric value from the return value of :ascii
            " This matches the two first pieces of the return value, e.g.
            " "<F>  70" => char: 'F', nr: '70'
            let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

            " Unicodeスカラ値
            let uniHex = printf('%X', nr)
            if strlen(uniHex) < 4
                for i in range(4 - strlen(uniHex))
                    let uniHex = '0' . uniHex
                endfor
            endif
            let uniHex = 'U+' . uniHex

            " iconvが利用可能ならfileencodingでの文字コードも表示する
            let fencStr = iconv(char, &encoding, &fileencoding)
            let fencHex = ''
            for i in range(strlen(fencStr))
                let fencHex = fencHex . printf('%X', char2nr(fencStr[i]))
            endfor
            let fencHex = '0x' . (strlen(fencHex) % 2 == 1 ? '0' : '') . fencHex

            let l:ccl = "'" . char . "' " . fencHex . " (" . uniHex . ")"

            if s:is_display(strlen(l:ccl), 'MyCharCode')
                return l:ccl
            endif

            let l:ccs = "'" . char . "' (" . uniHex . ")"
            return s:is_display(strlen(l:ccs), 'MyCharCode') ? l:ccs : ''
        endfunction " }}}

        function! MyFileencoding() " {{{
            let l:en = strlen(&fileencoding) ? &fileencoding : &encoding
            return s:is_display(strlen(en), 'MyFileencoding') ? l:en : ''
        endfunction " }}}

        function! MyFileformat() " {{{
            return s:is_display(strlen(&ff), 'MyFileformat') ? &ff : ''
        endfunction " }}}

        function! MyFilename() " {{{
            return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
             \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
             \  &ft == 'unite' ? unite#get_status_string() :
             \  &ft == 'vimshell' ? vimshell#get_status_string() :
             \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
             \ ('' != MyModified() ? ' ' . MyModified() : '')
        endfunction " }}}

        function! MyFiletype() " {{{
            let l:ft = strlen(&filetype) ? &filetype : 'no ft'
            return s:is_display(strlen(l:ft), 'MyFiletype') ? l:ft : ''
        endfunction " }}}

        function! MyFugitive() " {{{
            try
                if &filetype !~? '\v(vimfiler|gundo)'
                    let l:fg = fugitive#head()
                else
                    throw 'vimfiler_or_gundo'
                endif
            catch
                let l:fg = ''
            endtry
            return s:is_display(strlen(l:fg), 'MyFugitive') ? l:fg : ''
        endfunction " }}}

        function! MyGitgutter() " {{{
            " http://qiita.com/yuyuchu3333/items/20a0acfe7e0d0e167ccc
            if !neobundle#is_installed('vim-gitgutter')
                return ''
            endif
            let hunks = GitGutterGetHunkSummary()
            let symbols = [
             \  g:gitgutter_sign_added . ' ',
             \  g:gitgutter_sign_modified . ' ',
             \  g:gitgutter_sign_removed . ' '
             \  ]
            let ret = []
            for i in [0, 1, 2]
                if hunks[i] > 0
                    call add(ret, symbols[i] . hunks[i])
                endif
            endfor
            let l:gg = join(ret, ' ')
            return s:is_display(strlen(l:gg), 'MyGitgutter') ? l:gg : ''
        endfunction " }}}

        function! MyLineinfo() " {{{
            let l:cl = line('.')
            let l:cc = col('.')
            let l:li = printf('%d:%d', l:cl, l:cc)
            return s:is_display(strlen(l:li), 'MyLineinfo') ? l:li : ''
        endfunction " }}}

        function! MyMode() " {{{
            let l:ps = ''
            if &paste
                let l:ps = ' P'
            endif
            return lightline#mode() . l:ps
        endfunction " }}}

        function! MyModified() " {{{
            return &filetype =~ '\v(help|vimfiler|gundo)'
             \ ? ''  : &modified
             \ ? '+' : &modifiable
             \ ? ''  : '-'
        endfunction " }}}

        function! MyPercent() " {{{
            let l:cl = line('.')
            let l:ll = line('$')
            let l:pc = printf('%3d%%', 100 * l:cl / l:ll)
            return s:is_display(strlen(l:pc), 'MyPercent') ? l:pc : ''
        endfunction " }}}

        function! MyReadonly() " {{{
            return &ft !~? '\v(help|vimfiler|gundo)' && &ro ? 'x' : ''
        endfunction " }}}

        unlet s:colorscheme

        call neobundle#untap()
    endif
    " }}}

    " Plugin : linediff.vim =================================== {{{
    " https://github.com/AndrewRadev/linediff.vim
    " http://deris.hatenablog.jp/entry/2013/12/15/235606
    if neobundle#tap('linediff.vim')
        call neobundle#config({
         \  'autoload': {
         \      'commands': ['Linediff', 'LinediffReset']
         \  }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : neocomplcache.vim ============================== {{{
    " https://github.com/Shougo/neocomplcache.vim
    if neobundle#tap('neocomplcache.vim')
        call neobundle#config({
         \  'autoload': {'on_source': ['neosnippet.vim']}
         \ })

        function! neobundle#tapped.hooks.on_source(bundle)
            let g:neocomplcache_enable_at_startup = 1
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : neomru.vim ===================================== {{{
    if neobundle#tap('neomru.vim')
        call neobundle#config({
         \  'autoload': {
         \      'unite_sources': ['file_mru']
         \  }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : neosnippet.vim ================================= {{{
    " https://github.com/Shougo/neosnippet.vim
    if neobundle#tap('neosnippet.vim')
        call neobundle#config({
         \  'autoload': {'insert': 1}
         \  })

        function! neobundle#tapped.hooks.on_source(bundle)
            let $SNIPPETDIRPATH=s:rc_dir.'/snippets'
            call s:MkdirP($SNIPPETDIRPATH)
            let g:neosnippet#snippets_directory=$SNIPPETDIRPATH

            " Plugin key-mappings.
            imap <C-k> <Plug>(neosnippet_expand_or_jump)
            smap <C-k> <Plug>(neosnippet_expand_or_jump)
            xmap <C-k> <Plug>(neosnippet_expand_target)

            " For snippet_complete marker.
            if has('conceal')
                set conceallevel=2 concealcursor=i
            endif
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : perlomni.vim =================================== {{{
    " https://github.com/c9s/perlomni.vim
    if neobundle#tap('perlomni.vim')
        call neobundle#config({
         \  'autoload': {'filetypes': ['perl']},
         \  })

        function! neobundle#tapped.hooks.on_source(bundle)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : perlvalidate-vim =============================== {{{
    " https://github.com/kana/vim-filetype-haskell
    if neobundle#tap('perlvalidate-vim')
        call neobundle#config({
         \  'autoload': {'filetypes': ['perl']},
         \  })

        function! neobundle#tapped.hooks.on_source(bundle)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : ref-hoogle {{{
    " https://github.com/ujihisa/ref-hoogle
    if neobundle#tap('ref-hoogle')
        call neobundle#config({
         \  'autoload': {
         \      'filetpyes': ['haskell'],
         \      'functions': [
         \          'ref#complete',
         \          'ref#ref',
         \      ],
         \      'unite_sources': ['ref'],
         \  }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : ref-sources.vim {{{
    " https://github.com/mojako/ref-sources.vim
    if neobundle#tap('ref-sources.vim')
        call neobundle#config({
         \  'autoload': {
         \      'functions': [
         \          'ref#complete',
         \          'ref#ref',
         \      ],
         \      'unite_sources': ['ref'],
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            let g:ref_auto_resize = 1
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : supertab ======================================= {{{
    " https://github.com/ervandew/supertab
    if neobundle#tap('supertab')
        call neobundle#config({
         \  'autoload': {'insert': 1}
         \ })

        call neobundle#untap()
    endif
    " }}}

    " Plugin : syntastic ====================================== {{{
    " https://github.com/scrooloose/syntastic
    " http://d.hatena.ne.jp/heavenshell/20120106/1325866974
    " http://d.hatena.ne.jp/itchyny/20130918/1379461406
    if neobundle#tap('syntastic')
        call neobundle#config({
         \  'autoload': {
         \      'commands'  : 'SyntasticCheck',
         \      'functions' : 'SyntasticStatuslineFlag',
         \  }})

        " 作者が教える！ lightline.vimの設定方法！ 〜 中級編 - 展開コンポーネントを理解しよう - プログラムモグモグ
        " http://itchyny.hatenablog.com/entry/20130918/1379461406
        " syntasticでperlのsyntaxcheckが動かなくなった件 - 呆備録
        " http://d.hatena.ne.jp/oppara/20140515/p1
        " 【Go × Vim】 VimでGoを書く - 2015 Spring
        " http://qiita.com/izumin5210/items/1f3c312edd7f0075b09c
        let g:syntastic_debug               = 0
        let g:syntastic_enable_perl_checker = 1
        let g:syntastic_mode_map            = {'mode': 'passive'}

        let g:syntastic_go_checkers   = ['go', 'golint']
        let g:syntastic_perl_checkers = ['perl', 'perlcritic', 'podchecker']

        augroup MyVimrc
            autocmd BufWritePost *.go      call s:syntastic()
            autocmd BufWritePost *.pl,*.pm call s:syntastic()
            autocmd BufWritePost *.py      call s:syntastic()
            autocmd BufWritePost *.t       call s:syntastic()
        augroup END
        function! s:syntastic()
            SyntasticCheck
            call lightline#update()
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : unite-codic.vim {{{
    if neobundle#tap('unite-codic.vim')
        call neobundle#config({
         \  'autoload': {
         \      'unite_sources': ['codic'],
         \  }})

        call neobundle#untap()
    endif
    " }}}

    " Plugin : unite-mark {{{
    " https://github.com/tacroe/unite-mark
    if neobundle#tap('unite-mark')
        call neobundle#config({
         \  'autoload': {
         \      'unite_sources':['mark']
         \ }})

        nnoremap <silent> [unite]m :<C-u>Unite mark<CR>

        call neobundle#untap()
    endif
    " }}}

    " Plugin : unite-outline {{{
    " https://github.com/Shougo/unite-outline
    if neobundle#tap('unite-outline')
        call neobundle#config({
         \  'autoload': {
         \      'unite_sources': ['outline'],
         \  }})

        " http://qiita.com/martini3oz/items/2cebdb805f45e7b4b901
        nnoremap <silent> [unite]o :<C-u>Unite -vertical outline<CR>

        call neobundle#untap()
    endif
    " }}}

    " Plugun : unite.vim {{{
    " https://github.com/Shougo/unite.vim
    " http://d.hatena.ne.jp/ruedap/20110110/vim_unite_plugin
    " http://d.hatena.ne.jp/ruedap/20110117/vim_unite_plugin_1_week
    if neobundle#tap('unite.vim')
        call neobundle#config({
         \  'autoload': {
         \      'commands': [
         \          {
         \              'name'     : 'Unite',
         \              'complete' : 'customlist,unite#complete_source'
         \          },
         \      ],
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            call unite#custom#profile('default', 'context', {
             \  'direction'        : 'botright',
             \  'ignorecase'       : 1,
             \  'prompt_direction' : 'top',
             \  'smartcase'        : 1,
             \  'start_insert'     : 1,
             \  })
        endfunction

        " バッファ及び最近使用したファイル一覧
        nnoremap <C-P> :<C-u>Unite -buffer-name=file buffer file_mru<CR>
        " ファイル一覧
        nnoremap <C-N> :<C-u>Unite file<CR>
        " 最近使用したファイル一覧
        nnoremap <C-Z> :<C-u>Unite file_mru<CR>

        " http://deris.hatenablog.jp/entry/2013/05/02/192415
        nnoremap [unite]  <Nop>
        nmap     <Space>u [unite]
        " grep
        nnoremap <silent> [unite]g :<C-u>Unite -buffer-name=search-buffer -no-empty grep<CR>
        nnoremap <silent> [unite]r :<C-u>UniteResume search-buffer<CR>

        " ESC二回で終了
        autocmd MyVimrc FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
        autocmd MyVimrc FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>

        " unite grep で pt を利用する
        " Ref. help unite-source-grep
        " http://blog.monochromegane.com/blog/2013/09/18/ag-and-unite/
        if executable('pt')
            " Use pt in unite grep source.
            " https://github.com/monochromegane/the_platinum_searcher
            let g:unite_source_grep_command       = 'pt'
            let g:unite_source_grep_default_opts  = '--nogroup --nocolor'
            let g:unite_source_grep_recursive_opt = ''
        elseif executable('ag')
            " Use ag in unite grep source.
            let g:unite_source_grep_command       = 'ag'
            let g:unite_source_grep_default_opts  =
             \  '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
             \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
            let g:unite_source_grep_recursive_opt = ''
        elseif executable('ack-grep')
            " Use ack in unite grep source.
            let g:unite_source_grep_command       = 'ack-grep'
            let g:unite_source_grep_default_opts  =
             \  '-i --no-heading --no-color -k -H'
            let g:unite_source_grep_recursive_opt = ''
        endif

        let g:unite_source_history_yank_list = 10000
        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-alignta ==================================== {{{
    " https://github.com/h1mesuke/vim-alignta
    if neobundle#tap('vim-alignta')
        call neobundle#config({
         \  'autoload': {
         \      'commands': [
         \          'Align',
         \          'AlignTsp',
         \          'Alignta',
         \      ],
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            " http://nanasi.jp/articles/vim/align/align_vim_ext.html
            " Alignを日本語環境で使用する
            let g:Align_xstrlen=3
            " AlignCtrlで変更した設定を初期状態に戻す
            command! -nargs=0 AlignReset call Align#AlignCtrl("default")
            " 空白揃へ (ref. \tsp or \Tsp)
            " http://nanasi.jp/articles/vim/align/align_vim_mapt.html
            command! -range -nargs=? AlignTsp :<line1>,<line2>Alignta <args> \S\+
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-anzu ======================================= {{{
    " https://github.com/osyo-manga/vim-anzu
    if neobundle#tap('vim-anzu')
        call neobundle#config({
         \  'autoload': {
         \      'function_prefix': 'anzu',
         \  }})

        function! neobundle#tapped.hooks.on_source(undle)
            " ヒットした檢索語が畫面中段に來るやうに
            " `zz'を付加してゐる。
            nmap n <Plug>(anzu-n-with-echo)zvzz
            nmap N <Plug>(anzu-N-with-echo)zvzz
            nmap * <Plug>(anzu-star-with-echo)zvzz
            nmap # <Plug>(anzu-sharp-with-echo)zvzz

            " 一定時間キー入力がないとき、ウインドウを移動したとき、
            " タブを移動したときに検索ヒット数の表示を消去する。
            autocmd MyVimrc CursorHold  * call anzu#clear_search_status()
            autocmd MyVimrc CursorHoldI * call anzu#clear_search_status()
            autocmd MyVimrc WinLeave    * call anzu#clear_search_status()
            autocmd MyVimrc TabLeave    * call anzu#clear_search_status()
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-filetype-haskell =========================== {{{
    " https://github.com/c9s/perlomni.vim
    if neobundle#tap('vim-filetype-haskell')
        call neobundle#config({
         \  'autoload': {'filetypes': ['haskell']},
         \ })

        function! neobundle#tapped.hooks.on_source(bundle)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-fugitive =================================== {{{
    " https://github.com/tpope/vim-fugitive
    if neobundle#tap('vim-fugitive')
        call neobundle#config({
         \  'autoload': {
         \      'commands'  : ['Gblame', 'Gdiff', 'Gwrite'],
         \      'functions' : ['fugitive#head'],
         \  }})

        " http://leafcage.hateblo.jp/entry/nebulavim_intro
        function! neobundle#tapped.hooks.on_post_source(bundle)
            doautoall fugitive BufNewFile
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-easymotion ================================= {{{
    " http://haya14busa.com/mastering-vim-easymotion/
    " https://github.com/Lokaltog/vim-easymotion
    if neobundle#tap('vim-easymotion')
        call neobundle#config({
         \  'autoload': {'mappings': ['/', '<Space>h', '<Space>j', '<Space>k', '<Space>l']}
         \ })

        function! neobundle#tapped.hooks.on_source(bundle)
            " Disable default mappings
            " If you are true vimmer, you should explicitly map keys by yourself.
            " Do not rely on default bidings.
            let g:EasyMotion_do_mapping = 0

            " n-character serach motion
            " Extend search motions with vital-over command line interface
            " Incremental highlight of all the matches
            " Now, you don't need to repetitively press `n` or `N` with
            " EasyMotion feature
            " `<Tab>` & `<S-Tab>` to scroll up/down a page with next match
            " :h easymotion-command-line
            nmap / <Plug>(easymotion-sn)
            xmap / <Plug>(easymotion-sn)
            omap / <Plug>(easymotion-tn)

            " hjkl motions
            map <Space>h <Plug>(easymotion-linebackward)
            map <Space>j <Plug>(easymotion-j)
            map <Space>k <Plug>(easymotion-k)
            map <Space>l <Plug>(easymotion-lineforward)
            " keep cursor colum when JK motion
            let g:EasyMotion_startofline = 0

            " Show target key with upper case to improve readability
            let g:EasyMotion_keys = ';HKLYUIOPNM,QWERTASDGZXCVBJF'
            let g:EasyMotion_use_upper = 1
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-gista ====================================== {{{
    " http://lambdalisue.hatenablog.com/entry/2014/07/01/203015
    " https://github.com/lambdalisue/vim-gista
    if neobundle#tap('vim-gista')
        call neobundle#config({
         \  'autoload': {
         \      'commands'      : ['Gista'],
         \      'mappings'      : '<Plug>(gista-',
         \      'unite_sources' : 'gista',
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            if g:gista#gist_api_url == 'https://api.github.com/'
                let g:gista#github_user = 'py0n'
            endif
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-gitgutter ================================== {{{
    " https://github.com/airblade/vim-gitgutter
    if neobundle#tap('vim-gitgutter')
        call neobundle#config({
         \  'autoload': {
         \      'functions': ['GitGutterGetHunkSummary'],
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            let g:gitgutter_sign_added = '✚'
            let g:gitgutter_sign_modified = '➜'
            let g:gitgutter_sign_removed = '✘'
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-go-extra =================================== {{{
    if neobundle#tap('vim-go-extra')
        call neobundle#config({
         \  'autoload': {
         \      'filetypes': ['go']
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            if executable('go') && exists('$GOPATH')
                call vimproc#system_bg('go get -u github.com/golang/lint/golint')
                call vimproc#system_bg('go get -u github.com/nsf/gocode')
                call vimproc#system_bg('go get -u github.com/rogpeppe/godef')
                call vimproc#system_bg('go get -u golang.org/x/tools/cmd/godoc')
                call vimproc#system_bg('go get -u golang.org/x/tools/cmd/goimports')
            else
                echoerr('Not defined GOPATH')
            endif

            let g:gofmt_command = 'goimports'
            augroup MyVimrc
                autocmd BufWritePre *.go Fmt
            augroup END
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-localrc ==================================== {{{
    " https://github.com/thinca/vim-localrc
    " http://d.hatena.ne.jp/thinca/20110108/1294427418
    if neobundle#tap('vim-localrc')
        let g:localrc_filename = '.local.vim'

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-pandoc-syntax ============================== {{{
    " https://github.com/vim-pandoc/vim-pandoc-syntax
    if neobundle#tap('vim-pandoc-syntax')
        call neobundle#config({
         \  'autoload': {
         \      'filetypes': ['markdown', 'pandoc', 'rst']
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-perl ======================================= {{{
    " https://github.com/vim-perl/vim-perl
    if neobundle#tap('vim-perl')
        call neobundle#config({
         \  'autoload': {'filetypes': ['perl']},
         \  })

        function! neobundle#tapped.hooks.on_source(bundle)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-precious =================================== {{{
    if neobundle#tap('vim-precious')
        call neobundle#config({
         \  'autoload': {
         \      'filetypes': ['html']
         \  }})

        function! neobundle#tapped.hooks.on_source(bundel)
            let g:context_filetype#filetypes = {
             \ 'html': [
             \     {
             \         'start'    : '<script\%( [^>]*\)\? type="text/javascript"\%( [^>]*\)\?>',
             \         'end'      : '</script>',
             \         'filetype' : 'javascript',
             \     }
             \ ],}
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-quickrun =================================== {{{
    " https://github.com/thinca/vim-quickrun
    if neobundle#tap('vim-quickrun')
        call neobundle#config({
         \  'autoload': {'commands': ['QuickRun']}
         \ })

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-ref ======================================== {{{
    " https://github.com/thinca/vim-ref
    if neobundle#tap('vim-ref')
        " http://blog.supermomonga.com/articles/vim/neobundle-sugoi-setting.html
        " http://d.hatena.ne.jp/osyo-manga/20130201/1359699217
        call neobundle#config({
         \  'autoload': {
         \      'commands': [{
         \          'name': 'Ref',
         \          'complete': 'customlist,ref#complete',
         \      }],
         \      'on_source': [
         \          'ref-hoogle',
         \          'ref-sources.vim',
         \      ],
         \  }})
        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-rooter {{{
    " https://github.com/airblade/vim-rooter
    if neobundle#tap('vim-rooter')
        autocmd BufEnter * :Rooter

        call neobundle#config({
         \  'autoload': {
         \      'commands': ['Rooter'],
         \  }})

        function! neobundle#tapped.hooks.on_source(bundle)
            let g:rooter_use_lcd = 1
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " Kwbd
    " バッファを削除してもウィンドウのレイアウトを崩さない
    " http://nanasi.jp/articles/vim/kwbd_vim.html
    command! Kwbd let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn

    " Plugin : vim-colors-solarized =========================== {{{
    "  https://github.com/altercation/vim-colors-solarized
    if neobundle#tap('vim-colors-solarized')
        " http://ethanschoonover.com/solarized
        let g:solarized_contrast="high"
        let g:solarized_hitrail=1
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_visibility="high"
        set background=dark
        colorscheme solarized
        " toggle bg
        call togglebg#map("<F5>")

        call neobundle#untap()
    endif
    " }}}

    " Plugin : vim-unite-giti {{{
    if neobundle#tap('vim-unite-giti')
        call neobundle#config({
         \  'autoload': {
         \      'unite-sources': ['giti', 'giti/*'],
         \  }})

        call neobundle#untap()
    endi
    " }}}

    " Plugin : wildfire.vim =================================== {{{
    " http://hail2u.net/blog/software/vim-wildfire.html
    " http://m.designbits.jp/14030411/
    " https://github.com/gcmt/wildfire.vim
    let g:wildfire_objects = ["i'", 'i"', 'i)', 'i]', 'i}', 'ip', 'it', 'i>']
    " }}}

    " Plugin ================================================== {{{
    " lightline.vimが共に無効である時の設定。
    if !neobundle#is_installed('lightline.vim')
        " 挿入モードの際、ステータスラインの色を変更する。
        function! IntoInsertMode()
            highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none
        endfunction
        function! OutInsertMode()
            highlight StatusLine guifg=darkblue guibg=white gui=none ctermfg=blue ctermbg=grey cterm=none
        endfunction
        autocmd MyVimrc InsertEnter * call IntoInsertMode()
        autocmd MyVimrc InsertLeave * call OutInsertMode()
        " カーソル下の文字コードを取得する
        " http://vimwiki.net/?tips%2F98
        function! GetB()
            let c = matchstr(getline('.'), '.', col('.') - 1)
            let c = iconv(c, &enc, &fenc)
            return String2Hex(c)
        endfunction
        " :help eval-examples
        " The function Nr2Hex() returns the Hex string of a number.
        function! Nr2Hex(nr)
            let n = a:nr
            let r = ""
            while n
                let r = '0123456789ABCDEF'[n % 16] . r
                let n = n / 16
            endwhile
            return r
        endfunction
        " The function String2Hex() converts each character in a string to a two
        " character Hex string.
        function! String2Hex(str)
            let out = ''
            let ix = 0
            while ix < strlen(a:str)
                let out = out . Nr2Hex(char2nr(a:str[ix]))
                let ix = ix + 1
            endwhile
            return out
        endfunction
        set statusline=%{GetB()}
    endif
    " }}}
endif
" }}}

" FileType : ファイルタイプ別設定 ========================= {{{

" FileType : Binary ======================================= {{{
" バイナリ編集(xxd)モード（vim -b での起動、もしくは *.bin で発動します）
" help xxd
" http://www.kawaz.jp/pukiwiki/?vim#ib970976
" http://jarp.does.notwork.org/diary/200606a.html#200606021
autocmd MyVimrc BufReadPre   *.bin let &binary=1
autocmd MyVimrc BufReadPost  *.bin if &binary | silent %!xxd -g 1
autocmd MyVimrc BufReadPost  *.bin set ft=xxd | endif
autocmd MyVimrc BufWritePre  *.bin if &binary | %!xxd -r | endif
autocmd MyVimrc BufWritePost *.bin if &binary | silent %!xxd -g 1
autocmd MyVimrc BufWritePost *.bin set nomod | endif
" }}}

" FileType : C  =========================================== {{{
" ':h ft-c-omni' を参照)
autocmd MyVimrc FileType c set omnifunc=ccomplete#Complete
" }}}

" FileType : CSS ========================================== {{{
" ':h ft-css-omni' を参照
autocmd MyVimrc FileType css set omnifunc=csscomplete#CompleteCSS
" }}}

" FileType : Git ========================================== {{{
autocmd MyVimrc FileType gitcommit set fileencoding=utf-8
" }}}

" FileType : Go =========================================== {{{
" 【Go × Vim】 VimでGoを書く - 2015 Spring
" http://qiita.com/izumin5210/items/1f3c312edd7f0075b09c
augroup MyVimrc
    autocmd Filetype go compiler go
    autocmd Filetype go setlocal noexpandtab
    autocmd Filetype go setlocal shiftwidth=4
    autocmd Filetype go setlocal softtabstop=0
    autocmd Filetype go setlocal tabstop=4
augroup END
" }}}

" FileType : Haskell ====================================== {{{
autocmd MyVimrc BufRead,BufNewFile *.hs set filetype=haskell
autocmd MyVimrc FileType haskell set expandtab
autocmd MyVimrc FileType haskell set nosmartindent
autocmd MyVimrc FileType haskell set shiftwidth=2
autocmd MyVimrc FileType haskell set softtabstop=2
autocmd MyVimrc FileType haskell set tabstop=8
" }}}

" FileType : JavaScript =================================== {{{
" ':h ft-javascript-omni' を参照
autocmd MyVimrc FileType javascript set shiftwidth=2
autocmd MyVimrc FileType javascript set softtabstop=2
autocmd MyVimrc FileType javascript set tabstop=2
autocmd MyVimrc FileType javascript set omnifunc=javascriptcomplete#CompleteJS
" }}}

" FileType : PHP ========================================== {{{
" ':h ft-php-omni' を参照
autocmd MyVimrc BufRead,BufNewFile *.inc set filetype=php
autocmd MyVimrc FileType php set omnifunc=phpcomplete#CompletePHP
"	Exuberant ctags 5.7j1 が UTF-8 のソースでは
"	うまく動かないのでコメントアウト。
"	autocmd FileType php nmap <silent> <F4>
"		\ :!ctags -f %:p:h/tags
"		\ -R
"		\ --jcode=utf8
"		\ --exclude=*.js
"		\ --exclude=*.css
"		\ --exclude=*.htm
"		\ --exclude=.snapshot
"		\ --langmap="php:+.inc"
"		\ -h ".php.inc"
"		\ --totals=yes
"		\ --tag-relative=yes
"		\ --PHP-kinds=+cf-v %:p:h<CR>
"	autocmd FileType php set tags=./tags,tags
" }}}

" FileType : Pandoc ======================================= {{{
autocmd MyVimrc BufRead,BufNewFile *.md set filetype=pandoc
" https://sites.google.com/site/vimdocja/usr_25-html#25.4
" 禁則処理關係。
autocmd MyVimrc FileType pandoc setlocal display=lastline
autocmd MyVimrc FileType pandoc setlocal linebreak
autocmd MyVimrc FileType pandoc setlocal textwidth=0
" }}}

" FileType : Perl ========================================= {{{
autocmd MyVimrc BufRead,BufNewFile *.p[lm] set filetype=perl
autocmd MyVimrc BufRead,BufNewFile *.psgi  set filetype=perl
autocmd MyVimrc BufRead,BufNewFile *.t     set filetype=perl
autocmd MyVimrc BufRead,BufNewFile *.cgi   set filetype=perl
autocmd MyVimrc BufRead,BufNewFile *.tdy   set filetype=perl
autocmd MyVimrc FileType perl set expandtab
autocmd MyVimrc FileType perl set smarttab
" Vimでカーソル下のPerlモジュールを開く
" http://d.hatena.ne.jp/spiritloose/20060817/1155808744
autocmd MyVimrc FileType perl set isfname-=-
autocmd MyVimrc FileType perl nnoremap [perl]   <Nop>
autocmd MyVimrc FileType perl nmap     <Space>p [perl]
autocmd MyVimrc FileType perl nnoremap <buffer> [perl]f :%!perltidy<CR>
autocmd MyVimrc FileType perl vnoremap [perl]   <Nop>
autocmd MyVimrc FileType perl vmap     <Space>p [perl]
autocmd MyVimrc FileType perl vnoremap <buffer> [perl]f :!perltidy<CR>
" }}}

" FileType : Python ======================================= {{{
autocmd MyVimrc FileType python set expandtab
autocmd MyVimrc FileType python set smarttab
autocmd MyVimrc FileType python set omnifunc=pythoncomplete#Complete
" http://vim.sourceforge.net/scripts/script.php?script_id=30
" autocmd MyVimrc FileType python source $HOME/.vim/plugin/python.vim
" http://stackoverflow.com/questions/15285032/autopep8-with-vim
if executable('autopep8')
    autocmd MyVimrc BufWritePost *.py,*.pt !autopep8 --in-place <afile>
endif
" }}}

" FileType : R ============================================ {{{
autocmd MyVimrc BufRead,BufNewFile *.R set filetype=r
" }}}

" FileType : Ruby ========================================= {{{
" ':h ft-ruby-omni' を参照
if has('ruby')
    let g:rubycomplete_buffer_loading=1
    let g:rubycomplete_classes_in_global=1
    let g:rubycomplete_rails=1

    autocmd MyVimrc FileType ruby set noexpandtab
    autocmd MyVimrc FileType ruby set omnifunc=rubycomplete#CompleteTags
endif
" }}}

" FileType : SQL ========================================== {{{
" ':h ft-sql-omni' を参照
autocmd MyVimrc FileType sql set omnifunc=sqlcomplete#CompleteTags
" }}}

" FileType : Vim ========================================== {{{
" http://kannokanno.hatenablog.com/entry/20120805/1344115812
" ':help ft-vim-indent' を参照。
function! s:set_vim_indent_cont()
    if &shiftwidth >= 3
        let g:vim_indent_cont=&shiftwidth-3
    else
        let g:vim_indent_cont=0
    endif
endfunction
autocmd MyVimrc FileType vim call s:set_vim_indent_cont()
" }}}

" FileType : XML ========================================== {{{
" ':h ft-xml-omni' を参照
autocmd MyVimrc FileType xml set omnifunc=xmlcomplete#CompleteTags
" }}}

" FileType : (X)HTML ====================================== {{{
" ':h ft-xhtml-omni' を参照
autocmd MyVimrc BufRead,BufNewFile *.tmpl set filetype=html
autocmd MyVimrc FileType html setlocal expandtab
autocmd MyVimrc FileType html setlocal shiftwidth=2
autocmd MyVimrc FileType html setlocal smarttab
autocmd MyVimrc FileType html setlocal softtabstop=2
autocmd MyVimrc FileType html setlocal tabstop=2
autocmd MyVimrc FileType html setlocal omnifunc=htmlcomplete#CompleteTags
" }}}

" FileType : YAML ========================================= {{{
autocmd MyVimrc FileType yaml setlocal expandtab
autocmd MyVimrc FileType yaml setlocal shiftwidth=2
autocmd MyVimrc FileType yaml setlocal softtabstop=2
autocmd MyVimrc FileType yaml setlocal tabstop=8
" }}}

" その他 (File Type) ====================================== {{{
" ':h ft-syntax-omni' を参照
" ※これが一番最後。
if exists("+omnifunc")
    autocmd MyVimrc Filetype *
     \   if &omnifunc == "" |
     \           setlocal omnifunc=syntaxcomplete#Complete |
     \   endif
endif
" }}}

" }}}

" Backup : バックアップ設定 =============================== {{{
" :help backup 参照
set nobackup
set nowritebackup
" }}}

" Mark : マーク設定 ======================================= {{{
" http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908

if !exists('s:markrement_chars')
    let s:markrement_chars = [
     \  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
     \  'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
     \  'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
     \  'y', 'z'
     \  ]
endif

function! s:AutoMarkrement()
    if !exists('b:markrement_pos')
        let b:markrement_pos = 0
    else
        let b:markrement_pos = (b:markrement_pos + 1) % len(s:markrement_chars)
    endif
    execute 'mark' s:markrement_chars[b:markrement_pos]
    echo 'marked' s:markrement_chars[b:markrement_pos]
endfunction

noremap [Mark] <Nop>
nmap    m      [Mark]

" 現在位置をマーク
nnoremap <silent>[Mark]m :<C-u>call <SID>AutoMarkrement()<CR>

" 次/前のマーク
nnoremap [Mark]n ]`
nnoremap [Mark]p [`

" マーク一覧
nnoremap [Mark]l :<C-u>marks<CR>
" }}}

" Edit : 編集設定 ========================================= {{{
"ファイルタイプの自動識別を有効にする (':help incompatible-7' を参照)
"更にファイルタイププラグインを有効にする。
filetype plugin indent on
"" ファイルを開く度にカレントディレクトリを変更する
"set autochdir
"オートインデントする
set autoindent
"BSが改行、autoindentを超えて動作する
"オートインデント、改行、インサートモード開始直後にBSキーで
"削除できるようにする
set backspace=indent,eol,start
" Cインデントの設定
set cinoptions&
set cinoptions+=:0
" クリップボードを共有する
" 選択した際に自動でクリップボードにコピーする
" http://pky.jp/?p=24
set clipboard&
set clipboard+=unnamed,autoselect
" コマンドラインの高さ
set cmdheight=1
" バッファが変更されているとき、コマンドをエラーにするのではなく、
" 保存するかどうかを確認する
set confirm
"C プログラムの自動インデントを無効にする(smartindent の為)
set nocindent
" 日本語行を連結する際に空白を挿入しない
set formatoptions&
set formatoptions+=mM
" 新しいバッファを開く際にメッセージを出力しない
" バッファを保存しなくても他のバッファを表示できるようにする
set hidden
"" ヒストリの保存数
"set history=50
"モードラインの有効行を10する
set modeline
set modelines=10
"" マウスを有効にする
"if has('mouse')
"	set mouse=a
"	set ttymouse=xterm2
"endif
"" 暫く入力が無い時に保存する
"" http://vim-users.jp/2009/07/hack36/
"autocmd CursorHold  * wall
"autocmd CursorHoldI * wall
" 8進数を無効にする (C-a, C-xなどに影響する)
set nrformats&
set nrformats-=octal
"" 画面最下行にルーラを表示する
"set ruler
"「賢い」インデントする
set smartindent
" Escの反応を素早くする。
" 但し、この設定を使用するときはEscを含むマッピングを全て無効にする。
" http://gajumaru.ddo.jp/wordpress/?p=1101
" http://stackoverflow.com/questions/23946748/vim-imap-jk-esc-not-working-even-with-escape-character
"set timeout timeoutlen=1000 ttimeoutlen=75
"" Visual blockモードでフリーカーソルを有効にする
"set virtualedit=block
"" カーソルキーで行末/行頭を移動可能に設定
"set whichwrap=b,s,[,],<,>
" 強化されたコマンドライン補完
set wildmenu
" 自動的にディレクトリを作成する。
" http://vim-users.jp/2011/02/hack202/
autocmd MyVimrc BufWritePre * call s:MkdirP(expand('<afile>:p:h'))
" インサートモードから抜ける際にペーストモードも抜ける
" http://qiita.com/quwa/items/019250dbca167985fe32
autocmd MyVimrc InsertLeave * set nopaste
" }}}

" Search : 検索設定 {{{
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索時に最後まで行ったら最初に戻る
set wrapscan

" grepでptまたはackを使用 (unite-grepが設定されていないときのみ)
" http://beyondgrep.com/
" http://blog.blueblack.net/item_160
" http://d.hatena.ne.jp/secondlife/20080311/1205205348
" https://github.com/monochromegane/the_platinum_searcher
if !exists('g:unite_source_grep_command')
    if executable('pt')
        set grepprg=pt
    elseif executable('ag')
        set grepprg=ag
    elseif executable('ack-grep')
        set grepprg=ack-grep
    elseif executable('ack')
        set grepprg=ack
    endif
    autocmd MyVimrc QuickfixCmdPost grep cwindow
endif
" }}}

" Decoration : 装飾設定 =================================== {{{
" シンタックスハイライトを有効にする
syntax enable

" http://vim-users.jp/2009/08/hack64/
" https://github.com/itchyny/lightline.vim
if !has('gui_running')
    set t_Co=256
endif

if has('win32unix')
    " minttyでモードによってカーソルの形状を変更する 。
    " http://koturn.hatenablog.com/entry/2013/08/13/020116
    " http://qiita.com/usamik26/items/f733add9ca910f6c5784
    let &t_ti.="\e[1 q" " 端末をtermcapモードにする
    let &t_SI.="\e[5 q" " 挿入モード開始でバー型
    let &t_EI.="\e[1 q" " 挿入モード終了でブロック型
    let &t_te.="\e[0 q" " termcapモードを抜ける
endif

" ノーマルモードで行を目立たせる
" http://blog.remora.cx/2012/10/spotlight-cursor-line.html
set cursorline
autocmd MyVimrc InsertEnter * set nocursorline
autocmd MyVimrc InsertLeave * set cursorline

" 行末の空白を目立たせる。
" 全角空白を目立たせる。
" http://d.hatena.ne.jp/tasukuchan/20070816/1187246177
" http://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample#TOC-4
function! VisualizeInvisibleSpace()
    highlight InvisibleSpace term=underline ctermbg=red guibg=red
    match InvisibleSpace /　\|[　	 ]\+$/
endfunction
autocmd MyVimrc BufEnter * call VisualizeInvisibleSpace()
"行番号を表示しない
set nonumber
" 音を鳴らさない、画面更新をしない
set noerrorbells
set novisualbell
"set visualbell t_vs=
" マクロ実行中に画面作業画を行わない
set lazyredraw
" Winでディレクトリパスの区切り文字に「/」を使えるように
if exists('+shellslash')
    set shellslash
endif
"括弧入力時の対応する括弧を表示
set showmatch
" 括弧の対応表示時間
set showmatch matchtime=1
" タブの左側にカーソル表示
" http://hatena.g.hatena.ne.jp/hatenatech/20060515/1147682761
" ※末尾の空白は必要。
"set listchars=tab:\ \ 
"set list
"タブ幅を設定する
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
"入力中のコマンドをステータスに表示する
set showcmd
"検索結果文字列のハイライトを有効にする
set hlsearch
" https://powerline.readthedocs.org/en/latest/tipstricks.html#vim
" ステータスラインを常に表示
set laststatus=2
set noshowmode
" タイトルを表示
set title
set scrolloff=4
" }}}

" Keymap : キーマップ設定 ================================= {{{

" # mapとnoremapの違い
"
" mapは *再帰的* にマップする。noremapは *一度だけ* マップする。
"
" * http://cocopon.me/blog/?p=3871
" * http://sangoukan.xrea.jp/cgi-bin/tDiary/?date=20120227#p01

" 特殊文字
inoremap <C-v>a â
inoremap <C-v>e ê
inoremap <C-v>i î
inoremap <C-v>o ô
inoremap <C-v>u û
" 表示行単位で行移動する
" http://deris.hatenablog.jp/entry/2013/05/02/192415
nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k
" 行頭、行末移動を押し易くする
" http://deris.hatenablog.jp/entry/2013/05/02/192415
"noremap  <Space>h ^ "vim-easymotionの為にコメントアウト
"noremap  <Space>l $ "vim-easymotionの為にコメントアウト
noremap  <Space>m %
nnoremap <Space>/ *zz
" 中段を維持しながら上下移動
nnoremap <C-f> <C-f>zz
nnoremap <C-b> <C-b>zz
" フレームサイズを怠惰に変更する
" Key repeat hack for resizing splits, i.e., <C-w>+++- vs <C-w>+<C-w>+<C-w>-
" see: http://www.vim.org/scripts/script.php?script_id=2223
nmap <C-w>+ <C-w>+<SID>ws
nmap <C-w>- <C-w>-<SID>ws
nmap <C-w>> <C-w>><SID>ws
nmap <C-w>< <C-w><<SID>ws
nnoremap <script> <SID>ws+ <C-w>+<SID>ws
nnoremap <script> <SID>ws- <C-w>-<SID>ws
nnoremap <script> <SID>ws> <C-w>><SID>ws
nnoremap <script> <SID>ws< <C-w><<SID>ws
nmap <SID>ws <Nop>
" ヘルプ検索
nnoremap <F1> K
" 現在開いているviスクリプトを実行する
nnoremap <F8> :source %<CR>
" 強制終了保存を無効にする
" http://deris.hatenablog.jp/entry/2013/05/02/192415
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q  <Nop>
" ヒットした検索後が画面の中段に来るように
nnoremap n  nzz
nnoremap N  Nzz
nnoremap *  *zz
nnoremap #  #zz
nnoremap g* g*zz
nnoremap g# g#zz
" Escをjkで代用する。
" http://deris.hatenablog.jp/entry/2014/05/20/235807
inoremap jk <Esc>
vnoremap jk <Esc>
" command履歴
" http://lingr.com/room/vim/archives/2014/12/13#message-20830819
cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>
cnoremap <C-p>  <Up>
cnoremap <C-n>  <Down>
" 括弧の補完
" http://qiita.com/kuwana/items/d9778a9ec42a53b3aa10
inoremap "        ""<LEFT>
inoremap '        ''<LEFT>
inoremap (<Enter> ()<Left>
inoremap <<Enter> <><Left>
inoremap [<Enter> []<Left>
inoremap {<Enter> {}<Left>
" 挿入モードでのEsc押下後の待ちを無くす
" http://ttssh2.sourceforge.jp/manual/ja/usage/tips/vim.html
let &t_SI .= "\e[?7727h"
let &t_EI .= "\e[?7727l"
inoremap <special> <Esc>O[ <Esc>
" }}}

" GUI設定 ================================================= {{{
if has("gui_running")
    " フォントを設定する
    if has("gui_gtk2")
        set guifont=Ricty\ 12
        if has("xim")
            " GTK2版gVimで"BadWindow (invalid Window parameter)"エラーが
            " 出ない樣に。
            " http://memo.officebrook.net/20080306.html
            " http://d.hatena.ne.jp/pasela/20080709/gvim
            set imactivatekey=C-space
        endif
    elseif has("gui_win32")
        set guifont=Ricty:h12
        set guifontwide=Ricty:h12
    elseif has("gui_macvim")
        set guifont=Menlo\ Regular:h14
        set guifontwide=Osaka:h14
    endif
    " 插入モードや檢索で日本語入力状態になるのを防ぐ。
    " http://memo.officebrook.net/20080312.html
    " http://d.hatena.ne.jp/pasela/20080709/gvim
    if has("multi_byte_ime") || has("xim")
        set iminsert=0
        set imsearch=0
        inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
        nnoremap / :set imsearch=0<CR>/
        nnoremap ? :set imsearch=0<CR>?
    endif
endif
" }}}

" Scouter : 戦闘力計測 ==================================== {{{
" http://vim-users.jp/2009/07/hack-39/
function! Scouter(file, ...)
    let pat = '^\s*$\|^\s*"'
    let lines = readfile(a:file)
    if !a:0 || !a:1
        let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
    endif
    return len(filter(lines,'v:val !~ pat'))
endfunction
command! -bar -bang -nargs=? -complete=file Scouter
 \ echo Scouter(empty(<q-args>)
 \   ? $MYVIMRC
 \   : expand(<q-args>), <bang>0)
command! -bar -bang -nargs=? -complete=file GScouter
 \ echo Scouter(empty(<q-args>)
 \   ? $MYGVIMRC
 \   : expand(<q-args>), <bang>0)
" }}}

" Resource : リソースファイル ============================= {{{

" 編集・再読込 ============================================ {{{
command! Ev edit   $MYVIMRC
command! Rv source $MYVIMRC
" }}}

" 外部リソースファイル読込 ================================ {{{
if has('win32') || has('win32unix') || has('win64')
    let $LOCALRC = expand('~/_vimrc.local')
elseif has('unix')
    let $LOCALRC = expand('~/.vimrc.local')
endif
if filereadable($LOCALRC)
    source $LOCALRC
endif
" }}}

" }}}

" # Vim 7.x 用の設定。
"
" 基本は以下の URL を參照にした。
"
" *Example vimrc - Vim Tips Wiki*
"   ~ http://vim.wikia.com/wiki/VimTip1628
" *vim-jp &raquo; Hack #144: 分かりやすく副作用のないKey-mappingsを定義する*
"   ~ http://vim-jp.org/vim-users-jp/2010/05/04/Hack-144.html
" *vim-jp &raquo; Hack #59: 分かりやすいKey-mappingsを定義する*
"   ~ http://vim-jp.org/vim-users-jp/2009/08/19/Hack-59.html
" *vimrc/9 - VimWiki*
"   ~ http://vimwiki.net/?vimrc/9
" *vimrcアンチパターン - rbtnn雑記*
"   ~ http://rbtnn.hateblo.jp/entry/2014/11/30/174749
" *vimでキーマッピングする際に考えたほうがいいこと - derisの日記*
"   ~ http://deris.hatenablog.jp/entry/2013/05/02/192415
" *「立て！立つんだビムー！」 - sorry, uninuplemented:*
"   ~ http://rhysd.hatenablog.com/entry/2012/12/19/001145
" *ずんWiki - vim*
"   ~ http://www.kawaz.jp/pukiwiki/?vim#hb6f6961
" *文字コードの自動認識*
"   ~ http://www.kawaz.jp/pukiwiki/?vim#cb691f26

" vim:set fileencoding=utf-8 fileformat=unix foldmethod=marker:
