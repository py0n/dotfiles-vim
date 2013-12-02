" Vim 7.x 用の設定。
"
" 基本は以下の URL を參照にした。
" http://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample
" http://vim.wikia.com/wiki/VimTip1628
" http://vimwiki.net/?vimrc/9
" http://www.kawaz.jp/pukiwiki/?vim#hb6f6961
"
" vi非互換(Vimの拡張機能を有効にする)
set nocompatible
" 本設定ファイルのエンコーディングを指定する
if has('multi_byte')
    scriptencoding utf-8
endif
" *NIX, Win32, Cygwinでのパスの違いを吸収する
if has('win32') || has('win32unix') || has('win64')
    let $CFGHOME=expand('~/vimfiles')
    let $LOCALRC=expand('~/_vimrc.local')
elseif has('unix')
    let $CFGHOME=expand('~/.vim')
    let $LOCALRC=expand('~/.vimrc.local')
else
    echomsg "Not Windows and not UNIX, use default configuration."
    finish
endif

" 函數 ==================================================== {{{
function! s:mkdir(dir)
    if !isdirectory(a:dir)
        if has('iconv') && has('multi_byte')
            call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
        else
            echomsg "Can't mkdir ".a:dir.", recompile with +iconv and +multi_bute."
        endif
    endif
endfunction
function! s:existcommand(cmd)
    return !empty(findfile(a:cmd, substitute($PATH, ':', ',', 'g')))
endfunction
" }}}

" テンプレート設定 ======================================== {{{
" テンプレートのディレクトリ。
let $TEMPLATEDIRPATH=$CFGHOME.'/template'
call s:mkdir($TEMPLATEDIRPATH)
" }}}

" バックアップ(backup)設定 ================================ {{{
" バックアップを作成しない
set nobackup
" backupファイルの保管場所
if &backup
    let $BACKUPPDIRPATH=$CFGHOME.'/tmp'
    call s:mkdir($BACKUPDIRPATH)
    set backupdir=$BACKUPDIRPATH
endif
" }}}

" スワップ(swap)設定 ====================================== {{{
" スワップファイルを作成する
set swapfile
" swapファイルの保管場所。
if &swapfile
    let $SWAPDIRPATH=$CFGHOME.'/tmp'
    call s:mkdir($SWAPDIRPATH)
    set directory=$SWAPDIRPATH
endif
" }}}

" 文字コード自動判定 ====================================== {{{
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if has('vim_starting')
    if &encoding !=# 'utf-8'
        set encoding=japan
        set fileencoding=japan
    endif
    if has('iconv')
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
    endif
    " 日本語を含まない場合はfileencodingにencodingを使うようにする
    if has('autocmd')
        function! AU_ReCheck_FENC()
            if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
                let &fileencoding=&encoding
            endif
        endfunction
        augroup MyCheckEnc
            autocmd!
        augroup END
        autocmd MyCheckEnc BufReadPost * call AU_ReCheck_FENC()
    endif
    " 改行コードの自動認識
    set fileformats=unix,dos,mac
    " □とか○の文字があってもカーソル位置がずれないようにする
    if exists('&ambiwidth')
        set ambiwidth=double
    endif
endif
" }}}

" 編集設定 ================================================ {{{
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
set clipboard&
set clipboard+=unnamed
" コマンドラインの高さ
set cmdheight=1
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
"「賢い」インデントする
set smartindent
"" 暫く入力が無い時に保存する
"" http://vim-users.jp/2009/07/hack36/
"autocmd CursorHold  * wall
"autocmd CursorHoldI * wall
" 8進数を無効にする (C-a, C-xなどに影響する)
set nrformats&
set nrformats-=octal
" http://gajumaru.ddo.jp/wordpress/?p=1101
set timeout timeoutlen=1000 ttimeoutlen=75
" 上書きに成功した後で削除される
"" Visual blockモードでフリーカーソルを有効にする
"set virtualedit=block
"" カーソルキーで行末/行頭を移動可能に設定
"set whichwrap=b,s,[,],<,>
" 強化されたコマンドライン補完
set wildmenu
"" 画面最下行にルーラを表示する
"set ruler
" バッファが変更されているとき、コマンドをエラーにするのではなく、
" 保存するかどうかを確認する
set confirm
" ファイルの上書きの前にバックアップを作らない
" backupがonで無い限り、いづれにせよ上書き前のバックアップは
set nowritebackup
" 今日の日付を入れておく。
" http://nanasi.jp/articles/howto/file/workingfile.html#id22
if exists("*strftime")
	let $TODAY = strftime('%Y%m%d')
endif
" 自動的にディレクトリを作成する。
" http://vim-users.jp/2011/02/hack202/
if has("autocmd")
    augroup MyAutoMkdir
        autocmd!
        autocmd BufWritePre * call s:mkdir(expand('<afile>:p:h'))
    augroup END
endif
" }}}

" 検索設定 ================================================ {{{
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" grepでackを使ふ
" http://blog.blueblack.net/item_160
" http://d.hatena.ne.jp/secondlife/20080311/1205205348
"set grepprg=ack\ --perl
if s:existcommand('ack-grep')
    set grepprg=ack-grep
elseif s:existcommand('ack')
    set grepprg=ack
endif
if has("autocmd")
    augroup MyAckGrep
        autocmd!
    augroup END
    autocmd QuickfixCmdPost grep cw
endif
" }}}

" 装飾設定 ================================================ {{{
"シンタックスハイライトを有効にする
if has("syntax")
	syntax enable

    " http://vim-users.jp/2009/08/hack64/
    " https://github.com/itchyny/lightline.vim
    if !has('gui_running')
        set t_Co=256
    endif

    " ノーマルモードで行を目立たせる
    " http://blog.remora.cx/2012/10/spotlight-cursor-line.html
    set cursorline
    if has("autocmd")
        augroup MyCursorLine
            autocmd!
        augroup END
        autocmd MyCursorLine InsertEnter * set nocursorline
        autocmd MyCursorLine InsertLeave * set cursorline
    endif
endif
" 行末の空白を目立たせる。
" 全角空白を目立たせる。
" http://d.hatena.ne.jp/tasukuchan/20070816/1187246177
" http://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample#TOC-4
if has('autocmd') && has('syntax')
	function! VisualizeInvisibleSpace()
		highlight InvisibleSpace term=underline ctermbg=red guibg=red
		match InvisibleSpace /　\|[　	 ]\+$/
	endfunction
	augroup VisualizeInvisibleSpace
		autocmd!
		autocmd BufEnter * call VisualizeInvisibleSpace()
	augroup END
endif
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
set listchars=tab:\ \ 
set list
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
" }}}

" キーマップ設定 ========================================== {{{
" 表示行単位で行移動する
" http://deris.hatenablog.jp/entry/2013/05/02/192415
nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k
" 行頭、行末移動を押し易くする
" http://deris.hatenablog.jp/entry/2013/05/02/192415
noremap <Space>h ^
noremap <Space>l $
noremap <Space>m %
nnoremap <Space>/ *
" 中段を維持しながら上下移動
nmap <Space>j <C-f>zz
nmap <Space>k <C-b>zz
" フレームサイズを怠惰に変更する
map <kPlus>  <C-W>+
map <kMinus> <C-W>-
"" ヘルプ検索
"nnoremap <F1> K
" 現在開いているviスクリプトを実行する
nnoremap <F8> :source %<CR>
" 強制終了保存を無効にする
" http://deris.hatenablog.jp/entry/2013/05/02/192415
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q  <Nop>
" ヒットした検索後が画面の中段に来るように
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
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

" プラグイン読込 (NeoBundle) ============================== {{{
" https://github.com/Shougo/neobundle.vim
" http://blog.supermomonga.com/articles/vim/neobundle-sugoibenri.html
" http://qiita.com/rbtnn/items/39d9ba817329886e626b
" http://vim-users.jp/2011/10/hack238/

" NeoBundleのディレクトリ。
" https://github.com/deris/Config/blob/master/.vimrc
let $VIMBUNDLEDIRPATH=$CFGHOME.'/bundle'
let $NEOBUNDLEDIRPATH=$VIMBUNDLEDIRPATH.'/neobundle.vim'
let $NEOBUNDLEFILEPATH=$NEOBUNDLEDIRPATH.'/autoload/neobundle.vim'

" ディレクトリが存在しなければ作成する。
call s:mkdir($VIMBUNDLEDIRPATH)

" neobundle.vimが無い場合は終了。
if !filereadable($NEOBUNDLEFILEPATH)
    if (has('unix') || has('win32unix')) && s:existcommand('git')
        " https://github.com/joedicastro/dotfiles/blob/master/vim/vimrc
        silent !git clone https://github.com/Shougo/neobundle.vim
         \  $NEOBUNDLEDIRPATH
    else
        echomsg "Not installed NeoBundle (neobundle.vim) plugin"
        finish
    endif
endif

if has('vim_starting')
    set runtimepath&
    set runtimepath+=$NEOBUNDLEDIRPATH
endif

call neobundle#rc($VIMBUNDLEDIRPATH)

" neobundle.vimをneobundle自信で管理する。
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/vimproc', {
 \  'build' : {
 \      'cygwin'  : 'make -f make_cygwin.mak',
 \      'mac'     : 'make -f make_mac.mak',
 \      'unix'    : 'make -f make_unix.mak',
 \      'windows' : 'make -f make_mingw32.mak'
 \  }}

NeoBundle 'Shougo/neocomplcache.vim'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'c9s/perlomni.vim'
NeoBundle 'ervandew/supertab.git'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'kana/vim-filetype-haskell'
NeoBundle 'mattn/perlvalidate-vim'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-surround.git'
NeoBundle 'vim-perl/vim-perl'
NeoBundle 'vim-scripts/cecutil.git'
NeoBundle 'vim-scripts/newspaper.vim.git'

" ctrlp.vim
NeoBundleLazy 'kien/ctrlp.vim'
NeoBundleLazy 'sgur/ctrlp-extensions.vim', {
 \  'depends': ['kien/ctrlp.vim']
 \  }

" ghcmod-vim
NeoBundleLazy 'eagletmt/ghcmod-vim', {
 \  'depends': ['Shougo/vimproc'],
 \  'external_commands': ['ghc-mod'],
 \  }

" neco-ghc
NeoBundleLazy 'ujihisa/neco-ghc', {
 \  'external_commands': ['ghc-mod']
 \  }

" neosnippet.vim
NeoBundle 'Shougo/neosnippet.vim', {
 \  'depends' : [ 'Shougo/neocomplcache.vim' ]
 \  }

" unite.vim
NeoBundleLazy 'Shougo/unite.vim'
NeoBundleLazy 'h1mesuke/unite-outline', {
 \  'depends': ['Shougo/unite.vim'],
 \  }

" syntastic
NeoBundleLazy 'scrooloose/syntastic'

" vim-alignta
NeoBundle 'h1mesuke/vim-alignta'

" vim-anzu
NeoBundleLazy 'osyo-manga/vim-anzu'

" vim-fugitive & gitv
NeoBundleLazy 'tpope/vim-fugitive', {
 \  'external_commands': ['git']
 \  }
NeoBundleLazy 'gregsexton/gitv', {
 \  'depends' : ['tpope/vim-fugitive'],
 \  'external_commands': ['git'],
 \  }

" vim-gitgutter
NeoBundleLazy 'airblade/vim-gitgutter'

" vim-localrc
" Cygwin + vimではファイルを開くのが遅くなるので使用しない。
NeoBundle 'thinca/vim-localrc', {
 \  'disabled': has('win32unix')
 \  }

" vim-pandoc
NeoBundleLazy 'vim-pandoc/vim-pandoc', {
 \  'disabled': !has('python')
 \  }

" vim-ref
NeoBundleLazy 'thinca/vim-ref'
NeoBundleLazy 'mojako/ref-sources.vim', {
 \  'depends': ['thinca/vim-ref'],
 \  'external_commands': ['curl'],
 \  }
NeoBundleLazy 'ujihisa/ref-hoogle', {
 \  'depends': ['thinca/vim-ref'],
 \  'external_commands': ['hoogle'],
 \  }

" vim-rooter
NeoBundleLazy 'airblade/vim-rooter'

filetype plugin indent on     " Required!

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

" Plugin : ctrlp.vim ====================================== {{{
" https://github.com/kien/ctrlp.vim
if neobundle#tap('ctrlp.vim')
    let g:ctrlp_map = '<C-p>'
    let g:ctrlp_cmd = 'CtrlP'
    nnoremap <silent> <C-p> :<C-u>CtrlP<CR>

    call neobundle#config({
     \ 'autoload': {
     \      'commands': ['CtrlP'],
     \      'mappings': ['<C-p>'],
     \ }})

    function! neobundle#tapped.hooks.on_source(bundle)
        " http://qiita.com/items/5ece3f39481f6aab9bc5
        let g:ctrlp_clear_cache_on_exit = 0
        let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
        let g:ctrlp_max_depth = 40
        let g:ctrlp_max_files = 1000000
    endfunction

    call neobundle#untap()
endif

if neobundle#tap('ctrlp-extensions.vim')
    function! neobundle#tapped.hooks.on_source(bundle)
        " http://sgur.tumblr.com/post/21848239550/ctrlp-vim
        let g:ctrlp_extensions = [
         \  'cmdline', 'yankring', 'menu'
         \  ]
    endfunction

    call neobundle#untap()
endif
" }}}

" Plugin : ghcmod-vim ===================================== {{{
" https://github.com/eagletmt/ghcmod-vim
if neobundle#tap('ghcmod-vim')
    call neobundle#config({
     \  'autoload': {'filetypes': ['haskell']},
     \ })

    function! neobundle#tapped.hooks.on_source(bundel)
        let g:haddock_browser = "firefox"
    endfunction

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
                \     [ 'lineinfo', 'syntastic' ],
                \     [ 'percent' ],
                \     [ 'charcode', 'fileformat', 'fileencoding', 'filetype' ]
                \   ],
                \ },
                \ 'component_expand': {
                \   'syntastic': 'MySyntasticStatuslineFlag'
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
        if has('iconv') && has('multi_byte')
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
        if !neobundle#is_installed('vim-fugitive')
            return ''
        endif
        try
            if &filetype !~? '\v(vimfiler|gundo)'
                let l:fg = fugitive#head()
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

    " http://d.hatena.ne.jp/itchyny/20130918/1379461406
    function! MySyntasticStatuslineFlag() "{{{
        if neobundle#is_installed('syntastic')
            return SyntasticStatuslineFlag()
        else
            return ''
        endif
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

" Plugin : neocomplcache.vim ============================== {{{
" https://github.com/Shougo/neocomplcache.vim
if neobundle#tap('neocomplcache.vim')
    function! neobundle#tapped.hooks.on_source(bundle)
        let g:neocomplcache_enable_at_startup = 1
    endfunction

    call neobundle#untap()
endif
" }}}

" Plugin : neosnippet.vim ================================= {{{
" https://github.com/Shougo/neosnippet.vim
if neobundle#tap('neosnippet.vim')
    let $SNIPPETDIRPATH=$CFGHOME.'/snippets'
    call s:mkdir($SNIPPETDIRPATH)
    let g:neosnippet#snippets_directory=$SNIPPETDIRPATH

    " Plugin key-mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=i
    endif

    call neobundle#untap()
endif
"}}}

" Plugin : syntastic ====================================== {{{
" https://github.com/scrooloose/syntastic
" http://d.hatena.ne.jp/heavenshell/20120106/1325866974
" http://d.hatena.ne.jp/itchyny/20130918/1379461406
if neobundle#tap('syntastic')
    call neobundle#config({
     \  'autoload': {
     \      'functions': [
     \          'SyntasticCheck',
     \          'SyntasticStatuslineFlag',
     \      ],
     \  }})

    function! neobundle#tapped.hooks.on_source(bundle)
        let g:syntastic_mode_map = {'mode': 'passive'}
        augroup AutoSyntastic
            autocmd!
            autocmd BufWritePost *.pl,*.pm call s:syntastic()
            autocmd BufWritePost *.py      call s:syntastic()
            autocmd BufWritePost *.t       call s:syntastic()
        augroup END
        function! s:syntastic()
            SyntasticCheck
            if neobundle#is_installed('lightline.vim')
                call lightline#update()
            endif
        endfunction
    endfunction

    call neobundle#untap()
endif
" }}}

" Plugin : vim-alignta ==================================== {{{
" https://github.com/h1mesuke/vim-alignta
if neobundle#tap('vim-alignta')
    function! neobundle#tapped.hooks.on_source(bundle)
        " http://nanasi.jp/articles/vim/align/align_vim_ext.html
        " Alignを日本語環境で使用する
        let g:Align_xstrlen=3
        " AlignCtrlで変更した設定を初期状態に戻す
        command! -nargs=0 AlignReset call Align#AlignCtrl("default")
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
        nmap n <Plug>(anzu-n)zz
        nmap N <Plug>(anzu-N)zz
        nmap * <Plug>(anzu-star)zz
        nmap # <Plug>(anzu-sharp)zz

        augroup MyVimAnzu
            " 一定時間キー入力がないとき、ウインドウを移動したとき、
            " タブを移動したときに検索ヒット数の表示を消去する。
            autocmd!
            autocmd CursorHold  * call anzu#clear_search_status()
            autocmd CursorHoldI * call anzu#clear_search_status()
            autocmd WinLeave    * call anzu#clear_search_status()
            autocmd TabLeave    * call anzu#clear_search_status()
        augroup END
    endfunction

    call neobundle#untap()
endif
" }}}

" Plugin : vim-fugitive =================================== {{{
" https://github.com/tpope/vim-fugitive
if neobundle#tap('vim-fugitive')
    call neobundle#config({
     \  'autoload': {
     \      'commands': ['Gblame', 'Gdiff', 'Gwrite'],
     \      'function_prefix': 'fugitive',
     \      'on_source': ['gitv'],
     \  }})
    call neobundle#untap()
endif

" https://github.com/gregsexton/gitv
" http://cohama.hateblo.jp/entry/20120417/1334679297
" http://cohama.hateblo.jp/entry/20130517/1368806202
if neobundle#tap('gitv')
    call neobundle#config({
     \  'autoload': {
     \      'commands': ['Gitv'],
     \  }})

    function! neobundle#tapped.hooks.on_source(bundle)
        augroup Gitv
            autocmd!
            autocmd FileType git :setlocal foldlevel=99
        augroup END
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

" Plugin : vim-localrc ==================================== {{{
" https://github.com/thinca/vim-localrc
" http://d.hatena.ne.jp/thinca/20110108/1294427418
if neobundle#tap('vim-localrc')
"    call localrc#load('.local.vimrc', getcwd())

    call neobundle#untap()
endif
" }}}

" Plugin : vim-pandoc ===================================== {{{
" https://github.com/vim-pandoc/vim-pandoc
" http://lambdalisue.hatenablog.com/entry/2013/06/23/071344
if neobundle#tap('vim-pandoc')
    call neobundle#config({
     \  'autoload': {
     \      'filetypes': ['markdown', 'pandoc', 'rst', 'text', 'textile']
     \  }})

    function! neobundle#tapped.hooks.on_source(bundle)
        let g:pandoc_no_folding     = 1
        let g:pandoc_use_hard_wraps = 1
    endfunction

    call neobundle#untap()
endif
" }}}

" Plugin : vim-ref ======================================== {{{
" https://github.com/thinca/vim-ref
" https://github.com/mojako/ref-sources.vim
" https://github.com/ujihisa/ref-hoogle
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

if neobundle#tap('ref-sources.vim')
    call neobundle#config({
     \  'autoload': {
     \      'functions': [
     \          'ref#complete',
     \          'ref#ref',
     \      ]
     \  }})

    function! neobundle#tapped.hooks.on_source(bundle)
        let g:ref_auto_resize = 1
    endfunction

    call neobundle#untap()
endif

if neobundle#tap('ref-hoogle')
    call neobundle#config({
     \  'autoload': {
     \      'filetpyes': ['haskell'],
     \      'functions': [
     \          'ref#complete',
     \          'ref#ref',
     \      ],
     \  }})
    call neobundle#untap()
endif
" }}}

" Plugin : vim-rooter ===================================== {{{
" https://github.com/airblade/vim-rooter
if neobundle#tap('vim-rooter')
    augroup myRooter
        autocmd!
        " 2013/05/24 プラグイン本体に含まれていないもの。
        autocmd BufEnter *.hs,*.pl,*.pm,*.psgi,*.t,vimrc :Rooter
    augroup END

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

" Plugun : unite.vim ====================================== {{{
" https://github.com/Shougo/unite.vim
" http://d.hatena.ne.jp/ruedap/20110110/vim_unite_plugin
" http://d.hatena.ne.jp/ruedap/20110117/vim_unite_plugin_1_week
if neobundle#tap('unite.vim')
    " http://deris.hatenablog.jp/entry/2013/05/02/192415
    nnoremap [unite]  <Nop>
    nmap     <Space>u [unite]

    " http://qiita.com/martini3oz/items/2cebdb805f45e7b4b901
    nnoremap <silent> [unite]o :<C-u>Unite -vertical -no-quit outline<CR>

    call neobundle#config({
     \  'autoload': {
     \      'commands': ['Unite'],
     \      'on_source': ['unite-outline'],
     \  }})

    function! neobundle#tapped.hooks.on_source(bundle)
        " 入力モードで開始する
        let g:unite_enable_start_insert=1
        " バッファ一覧
        nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
        " ファイル一覧
        nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
        " レジスタ一覧
        nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
        " 最近使用したファイル一覧
        nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
        " 常用セット
        nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
        " 全部乗せ
        nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

        " unite.vim上でのキーマッピング
        function! s:unite_my_settings()
            " 単語単位からパス単位で削除するように変更
            imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
            " ESCキーを2回押すと終了する
            nmap <silent><buffer> <ESC><ESC> q
            imap <silent><buffer> <ESC><ESC> <ESC>q
        endfunction

        augroup MyUnite
            autocmd!
        augroup END
        autocmd MyUnite FileType unite call s:unite_my_settings()
        " ウィンドウを分割して開く
        autocmd MyUnite FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
        autocmd MyUnite FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
        " ウィンドウを縦に分割して開く
        autocmd MyUnite FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
        autocmd MyUnite FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
        " ESCキーを2回押すと終了する
        autocmd MyUnite FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
        autocmd MyUnite FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
    endfunction

    call neobundle#untap()
endif

if neobundle#tap('unite-outline')
    call neobundle#config({
     \  'autoload': {
     \      'unite_sources': ['outline'],
     \  }})
    call neobundle#untap()
endif
" }}}

" Plugin ================================================== {{{
" lightline.vimが共に無効である時の設定。
if !neobundle#is_installed('lightline.vim')
    " 挿入モードの際、ステータスラインの色を変更する。
    if has('autocmd') && has('syntax')
        function! IntoInsertMode()
            highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none
        endfunction
        function! OutInsertMode()
            highlight StatusLine guifg=darkblue guibg=white gui=none ctermfg=blue ctermbg=grey cterm=none
        endfunction
        augroup InsertHook
            autocmd!
            autocmd InsertEnter * call IntoInsertMode()
            autocmd InsertLeave * call OutInsertMode()
        augroup END
    endif
    " カーソル下の文字コードを取得する
    " http://vimwiki.net/?tips%2F98
    function! GetB()
        let c = matchstr(getline('.'), '.', col('.') - 1)
        if has('iconv') && has('multi_byte')
            let c = iconv(c, &enc, &fenc)
        endif
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

" Binary (File Type) ====================================== {{{
" バイナリ編集(xxd)モード（vim -b での起動、もしくは *.bin で発動します）
" help xxd
" http://www.kawaz.jp/pukiwiki/?vim#ib970976
" http://jarp.does.notwork.org/diary/200606a.html#200606021
if has('autocmd')
	augroup BinaryXXD
		autocmd!
		autocmd BufReadPre  *.bin let &binary=1
		autocmd BufReadPost *.bin if &binary | silent %!xxd -g 1
		autocmd BufReadPost *.bin set ft=xxd | endif
		autocmd BufWritePre *.bin if &binary | %!xxd -r | endif
		autocmd BufWritePost *.bin if &binary | silent %!xxd -g 1
		autocmd BufWritePost *.bin set nomod | endif
	augroup END
endif
" }}}

" C (File Type) =========================================== {{{
" ':h ft-c-omni' を参照)
if has('autocmd')
	augroup EditC
		autocmd!
		autocmd FileType c set omnifunc=ccomplete#Complete
	augroup END
endif
" }}}

" CSS (File Type) ========================================= {{{
" ':h ft-css-omni' を参照
if has('autocmd')
	augroup EditCSS
		autocmd!
		autocmd FileType css set omnifunc=csscomplete#CompleteCSS
	augroup END
endif
" }}}

" FileType : Git ========================================== {{{
if has('autocmd')
    augroup GitCommit
        autocmd!
        autocmd FileType gitcommit set fileencoding=utf-8
    augroup End
endif
" }}}

" FileType : Haskell ====================================== {{{
if has('autocmd')
    augroup EditHaskell
        autocmd!
        autocmd BufRead,BufNewFile *.hs set filetype=haskell
        autocmd BufWritePost,FileWritePost *.hs :GhcModCheck
        autocmd FileType haskell set expandtab
        autocmd FileType haskell set nosmartindent
        autocmd FileType haskell set shiftwidth=2
        autocmd FileType haskell set softtabstop=2
        autocmd FileType haskell set tabstop=8
        autocmd FileType haskell nnoremap [ghcmod] <Nop>
        autocmd FileType haskell nmap     <Space>g [ghcmod]
        autocmd FileType haskell nnoremap <buffer> [ghcmod]c :GhcModCheck<CR>
        autocmd FileType haskell nnoremap <buffer> [ghcmod]l :GhcModLint<CR>
        autocmd FileType haskell nnoremap <buffer> [ghcmod]t :GhcModTypeClear<CR>:GhcModType<CR>
        autocmd FileType haskell nnoremap <buffer> [ghcmod]tc :GhcModTypeClear<CR>
    augroup END
endif
" }}}

" JavaScript (File Type) ================================== {{{
" ':h ft-javascript-omni' を参照
if has('autocmd')
	augroup EditJavaScript
		autocmd!
		autocmd FileType javascript set shiftwidth=4
		autocmd FileType javascript set softtabstop=4
		autocmd FileType javascript set tabstop=4
		autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
	augroup END
endif
" }}}

" PHP (File Type) ========================================= {{{
" ':h ft-php-omni' を参照
if has('autocmd')
	augroup EditPHP
		autocmd!
		autocmd BufRead,BufNewFile *.inc set filetype=php
		autocmd FileType php set omnifunc=phpcomplete#CompletePHP
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
	augroup END
endif
" }}}

" FileType : Pandoc ======================================= {{{
if has('autocmd')
    augroup MyFileTypePandoc
        autocmd!
        autocmd BufRead,BufNewFile *.md set filetype=pandoc
    augroup END
endif
" }}}

" FileType : Perl ========================================= {{{
if has('autocmd')
    augroup EditPerl
        autocmd!
        autocmd BufRead,BufNewFile *.p[lm] set filetype=perl
        autocmd BufRead,BufNewFile *.psgi  set filetype=perl
        autocmd BufRead,BufNewFile *.t     set filetype=perl
        autocmd BufRead,BufNewFile *.cgi   set filetype=perl
        autocmd BufRead,BufNewFile *.tdy   set filetype=perl
        autocmd FileType perl set expandtab
        autocmd FileType perl set smarttab
        " Vimでカーソル下のPerlモジュールを開く
        " http://d.hatena.ne.jp/spiritloose/20060817/1155808744
        autocmd FileType perl set isfname-=-
        autocmd FileType perl nnoremap [perl]   <Nop>
        autocmd FileType perl nmap     <Space>p [perl]
        autocmd FileType perl nnoremap <buffer> [perl]t :%!perltidy<CR>
        autocmd FileType perl vnoremap [perl]   <Nop>
        autocmd FileType perl vmap     <Space>p [perl]
        autocmd FileType perl vnoremap <buffer> [perl]t :!perltidy<CR>
    augroup END
endif
" }}}

" FileType : Python ======================================= {{{
if has('autocmd')
    augroup EditPython
        autocmd!
        autocmd FileType python set expandtab
        autocmd FileType python set smarttab
        autocmd FileType python set omnifunc=pythoncomplete#Complete
        " http://vim.sourceforge.net/scripts/script.php?script_id=30
        " autocmd FileType python source $HOME/.vim/plugin/python.vim
    augroup END
    " http://stackoverflow.com/questions/15285032/autopep8-with-vim
    if executable('autopep8')
        augroup Autopep8
            autocmd!
            autocmd BufWritePost *.py,*.pt !autopep8 --in-place <afile>
        augroup END
    endif
endif
" }}}

" R (File Type) =========================================== {{{
if has('autocmd')
	augroup EditR
		autocmd!
		autocmd BufRead,BufNewFile *.R set filetype=r
	augroup END
endif
" }}}

" Ruby (File Type) ======================================== {{{
" ':h ft-ruby-omni' を参照
if has('ruby') && has('autocmd')
	augroup EditRuby
		autocmd!
		autocmd FileType ruby set omnifunc=rubycomplete#CompleteTags
		autocmd FileType ruby set noexpandtab
	augroup END
endif

let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1
" }}}

" SQL (File Type) ========================================= {{{
" ':h ft-sql-omni' を参照
if has('autocmd')
	augroup EditSQL
		autocmd!
		autocmd FileType sql set omnifunc=sqlcomplete#CompleteTags
	augroup END
endif
" }}}

" FileType : Vim ========================================== {{{
" http://kannokanno.hatenablog.com/entry/20120805/1344115812
" ':help ft-vim-indent' を参照。
if &sw >= 3
    let g:vim_indent_cont=&sw-3
else
    let g:vim_indent_cont=0
endif
" }}}

" XML (File Type) ========================================= {{{
" ':h ft-xml-omni' を参照
if has('autocmd')
	augroup EditXML
		autocmd!
		autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
	augroup END
endif
" }}}

" FileType : (X)HTML ====================================== {{{
" ':h ft-xhtml-omni' を参照
if has('autocmd')
    augroup MyEditHTML
        autocmd!
        autocmd BufRead,BufNewFile *.ep   set filetype=html
        autocmd BufRead,BufNewFile *.tmpl set filetype=html
        autocmd FileType html set expandtab
        autocmd FileType html set shiftwidth=2
        autocmd FileType html set smarttab
        autocmd FileType html set softtabstop=2
        autocmd FileType html set tabstop=2
        autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
    augroup END
endif
" }}}

" その他 (File Type) ====================================== {{{
" ':h ft-syntax-omni' を参照
" ※これが一番最後。
if has("autocmd") && exists("+omnifunc")
	augroup EditOther
		autocmd!
		autocmd Filetype *
			\   if &omnifunc == "" |
			\           setlocal omnifunc=syntaxcomplete#Complete |
			\   endif
	augroup END
endif
" }}}

" 戦闘力計測 ============================================== {{{
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

" リソースファイル編輯・再讀込 ============================ {{{
" vimrcをリロードする
command! Ev edit   $MYVIMRC
command! Rv source $MYVIMRC
" }}}

" 外部リソースファイル読込 ================================ {{{
" 外部ファイルを読み込む
" http://vim-users.jp/2009/12/hack108/
if filereadable(expand($LOCALRC))
	source $LOCALRC
endif
" }}}

" vim:set fileencoding=utf-8 fileformat=unix foldmethod=marker:
