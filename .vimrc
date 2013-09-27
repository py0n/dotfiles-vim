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
function! s:auto_mkdir(dir)
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
call s:auto_mkdir($TEMPLATEDIRPATH)
" }}}

" バックアップ(backup)設定 ================================ {{{
" バックアップを作成しない
set nobackup
" backupファイルの保管場所
if &backup
    let $BACKUPPDIRPATH=$CFGHOME.'/tmp'
    call s:auto_mkdir($BACKUPDIRPATH)
    set backupdir=$BACKUPDIRPATH
endif
" }}}

" スワップ(swap)設定 ====================================== {{{
" スワップファイルを作成する
set swapfile
" swapファイルの保管場所。
if &swapfile
    let $SWAPDIRPATH=$CFGHOME.'/tmp'
    call s:auto_mkdir($SWAPDIRPATH)
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
    augroup vimrc-auto-mkdir
        autocmd!
        autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'))
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
" Vim使用中はtmuxのステータスラインを隠す。
" http://qiita.com/Linda_pp/items/89aa2e4b55ea51ecdd59
if !has('gui_running') && $TMUX !=# ''
    augroup Tmux
        autocmd!
        autocmd VimEnter,VimLeave * silent !tmux set status
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
set noexpandtab
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
"" バッファ移動用キーマップ
"" QuickBuf を入れたのでコメントアウト。
"" F2: 前のバッファ
"" F3: 次のバッファ
"" F4: バッファ削除
"map <F2> <ESC>:bp<CR>
"map <F3> <ESC>:bn<CR>
map <F4> <ESC>:bw<CR>
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
"フレームサイズを怠惰に変更する
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
" http://qiita.com/rbtnn/items/39d9ba817329886e626b
" http://vim-users.jp/2011/10/hack238/
" https://github.com/Shougo/neobundle.vim

" NeoBundleのディレクトリ。
" https://github.com/deris/Config/blob/master/.vimrc
let $VIMBUNDLEDIRPATH=$CFGHOME.'/bundle'
let $NEOBUNDLEDIRPATH=$VIMBUNDLEDIRPATH.'/neobundle.vim'
let $NEOBUNDLEFILEPATH=$NEOBUNDLEDIRPATH.'/autoload/neobundle.vim'

" $HOME/.vim/bundleを作成する。
call s:auto_mkdir($VIMBUNDLEDIRPATH)

" neobundle.vimが無い場合は終了。
if !filereadable($NEOBUNDLEFILEPATH)
    echomsg "Not installed NeoBundle (neobundle.vim) plugin"
    finish
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
NeoBundle 'Shougo/unite.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'c9s/perlomni.vim'
NeoBundle 'ervandew/supertab.git'
NeoBundle 'h1mesuke/unite-outline.git'
NeoBundle 'h1mesuke/vim-alignta'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'kana/vim-filetype-haskell'
NeoBundle 'mattn/perlvalidate-vim'
NeoBundle 'mojako/ref-sources.vim.git'
NeoBundle 'osyo-manga/vim-anzu'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tpope/vim-surround.git'
NeoBundle 'ujihisa/neco-ghc.git'
NeoBundle 'vim-perl/vim-perl'
NeoBundle 'vim-scripts/cecutil.git'
NeoBundle 'vim-scripts/newspaper.vim.git'

" ctrlp.vim
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'sgur/ctrlp-extensions.vim', {
 \  'depends' : [ 'kien/ctrlp.vim' ]
 \  }

" ghcmod-vim
NeoBundleLazy 'eagletmt/ghcmod-vim', {
 \  'autoload' : { 'filetypes' : [ 'haskell' ] },
 \  'depends'  : [ 'Shougo/vimproc' ]
 \  }

" git
" http://d.hatena.ne.jp/cohama/20120417/1334679297
" http://d.hatena.ne.jp/cohama/20130517/1368806202
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'gregsexton/gitv', {
 \  'depends' : [ 'tpope/vim-fugitive' ]
 \  }

" neosnippet.vim
NeoBundle 'Shougo/neosnippet.vim', {
 \  'depends' : [ 'Shougo/neocomplcache.vim' ]
 \  }
" powerline
"NeoBundle 'taichouchou2/alpaca_powertabline'
"NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}

" ref-hoogle
if s:existcommand('hoogle')
    NeoBundle 'ujihisa/ref-hoogle', {
     \  'depends' : [ 'thinca/vim-ref' ]
     \  }
endif

" vim-pandoc
" http://lambdalisue.hatenablog.com/entry/2013/06/23/071344
if has('python') && s:existcommand('pandoc')
    NeoBundleLazy 'vim-pandoc/vim-pandoc', {
     \  'autoload': { 'filetypes': [
     \      'markdown', 'pandoc', 'rst', 'text', 'textile'
     \  ]}}
endif

" vim-powerline
"NeoBundle 'Lokaltog/vim-powerline.git'

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
let s:bundle = neobundle#get('ctrlp.vim')
function! s:bundle.hooks.on_source(bundle)
    " http://qiita.com/items/5ece3f39481f6aab9bc5
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
    let g:ctrlp_max_depth = 40
    let g:ctrlp_max_files = 1000000
endfunction
unlet s:bundle

let s:bundle = neobundle#get('ctrlp-extensions.vim')
function! s:bundle.hooks.on_source(bundle)
    " http://sgur.tumblr.com/post/21848239550/ctrlp-vim
    let g:ctrlp_extensions = ['cmdline', 'yankring', 'menu']
endfunction
unlet s:bundle
" }}}
"
" Plugin : ghcmod-vim ===================================== {{{
" https://github.com/eagletmt/ghcmod-vim
let s:bundle = neobundle#get('ghcmod-vim')
function! s:bundle.hooks.on_source(bundle)
    let g:haddock_browser = "firefox"
endfunction
unlet s:bundle
" }}}

" Plugin : gitv =========================================== {{{
" https://github.com/gregsexton/gitv
let s:bundle = neobundle#get('gitv')
function! s:bundle.hooks.on_source(bundle)
    augroup Gitv
        autocmd!
        " http://d.hatena.ne.jp/cohama/20120417/1334679297
        autocmd FileType git :setlocal foldlevel=99
    augroup END
endfunction
unlet s:bundle
" }}}

" Plugin : lightline.vim ================================== {{{
" http://d.hatena.ne.jp/itchyny/20130828/1377653592
" http://qiita.com/yuyuchu3333/items/20a0acfe7e0d0e167ccc
" https://github.com/itchyny/lightline.vim
let s:bundle = neobundle#get('lightline.vim')
if !empty(s:bundle)
    let s:colorscheme
                \ = empty(neobundle#get('vim-colors-solarized'))
                \ ? 'wombat'
                \ : 'solarized'
    let g:lightline = {
                \ 'colorscheme': s:colorscheme,
                \ 'mode_map': {'c': 'NORMAL'},
                \ 'active': {
                \   'left': [
                \     [ 'syntastic', 'mode' ],
                \     [ 'fugitive', 'gitgutter', 'filename', 'anzu' ]
                \   ],
                \   'right': [
                \     [ 'lineinfo' ],
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
        try
            if &filetype !~? '\v(vimfiler|gundo)' && exists('*fugitive#head')
                let l:fg = fugitive#head()
            endif
        catch
            let l:fg = ''
        endtry
        return s:is_display(strlen(l:fg), 'MyFugitive') ? l:fg : ''
    endfunction " }}}

    function! MyGitgutter() " {{{
        " http://qiita.com/yuyuchu3333/items/20a0acfe7e0d0e167ccc
        if !empty(neobundle#get('vim-gitgutter'))
            return ''
        endif
        if !exists('*GitGutterGetHunkSummary')
            return ''
        endif
        let symbols = [
                    \ g:gitgutter_sign_added . ' ',
                    \ g:gitgutter_sign_modified . ' ',
                    \ g:gitgutter_sign_removed . ' '
                    \ ]
        let hunks = GitGutterGetHunkSummary()
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
        if !empty(neobundle#get('syntastic'))
            return SyntasicStatuslineFlag()
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
endif
unlet s:bundle
" }}}

" Plugin : neocomplcache.vim ============================== {{{
" https://github.com/Shougo/neocomplcache.vim
let s:bundle = neobundle#get('neocomplcache.vim')
function! s:bundle.hooks.on_source(bundle)
    let g:neocomplcache_enable_at_startup = 1
endfunction
unlet s:bundle
" }}}

" Plugin : neosnippet.vim ================================= {{{
" https://github.com/Shougo/neosnippet.vim
let s:bundle = neobundle#get('neosnippet.vim')
if !empty(s:bundle)
    let $SNIPPETDIRPATH=$CFGHOME.'/snippets'
    call s:auto_mkdir($SNIPPETDIRPATH)
    let g:neosnippet#snippets_directory=$SNIPPETDIRPATH

    " Plugin key-mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=i
    endif
endif
unlet s:bundle
"}}}

" Plugin : powerline ====================================== {{{
let s:bundle = neobundle#get('powerline')
if !empty(s:bundle)
    let g:Powerline_symbols = "fancy"
    let g:Powerline_dividers_override = ['', [0x2b81], '', [0x2b83]]
    let g:Powerline_symbols_override = {
                \ 'BRANCH': [0x2b60],
                \ 'RO'    : 'RO',
                \ 'FT'    : 'FT',
                \ 'LINE'  : 'LN'
                \ }
    " https://powerline.readthedocs.org/en/latest/tipstricks.html#vim
    if ! has('gui_running')
        set ttimeoutlen=10
        augroup FastEscape
            autocmd!
            autocmd InsertEnter * set timeoutlen=0
            autocmd InsertLeave * set timeoutlen=1000
        augroup END
    endif
endif
unlet s:bundle
" }}}

" Plugin : syntastic ====================================== {{{
" https://github.com/scrooloose/syntastic
" http://d.hatena.ne.jp/heavenshell/20120106/1325866974
" http://d.hatena.ne.jp/itchyny/20130918/1379461406
let s:bundle = neobundle#get('syntastic')
if !empty(s:bundle)
    let g:syntastic_mode_map = { 'mode': 'passive' }
    augroup AutoSyntastic
        autocmd!
        autocmd BufWritePost *.pl,*.pm,*.t call s:syntastic()
    augroup END
    function s:syntastic()
        SyntasticCheck
        if !empty(neobundle#get('lightline.vim'))
            call lightline#update()
        endif
    endfunction
endif
unlet s:bundle
" }}}

" Plugin : vim-alignta ==================================== {{{
" https://github.com/h1mesuke/vim-alignta
let s:bundle = neobundle#get('vim-alignta')
function! s:bundle.hooks.on_source(bundle)
    " http://nanasi.jp/articles/vim/align/align_vim_ext.html
    " Alignを日本語環境で使用する
    let g:Align_xstrlen=3
    " AlignCtrlで変更した設定を初期状態に戻す
    command! -nargs=0 AlignReset call Align#AlignCtrl("default")
endfunction
unlet s:bundle
" }}}

" Plugin : vim-gitgutter ================================== {{{
" https://github.com/airblade/vim-gitgutter
let s:bundle = neobundle#get('vim-gitgutter')
if !empty(s:bundle)
    let g:gitgutter_sign_added = '✚'
    let g:gitgutter_sign_modified = '➜'
    let g:gitgutter_sign_removed = '✘'
endif
unlet s:bundle
" }}}

" Plugin : vim-anzu ======================================= {{{
" https://github.com/osyo-manga/vim-anzu
let s:bundle = neobundle#get('vim-anzu')
if !empty(s:bundle)
    nmap n <Plug>(anzu-n)
    nmap N <Plug>(anzu-N)
    nmap * <Plug>(anzu-star)
    nmap # <Plug>(anzu-sharp)

    augroup VimAnzu
        " 一定時間キー入力がないとき、ウインドウを移動したとき、
        " タブを移動したときに " 検索ヒット数の表示を消去する。
        autocmd!
        autocmd CursorHold,CursorHoldI,WinLeave,TabLeave * call anzu#clear_search_status()
    augroup END 
endif
unlet s:bundle
" }}}

" Plugin : vim-gitgutter ================================== {{{
" https://github.com/airblade/vim-gitgutter
let s:bundle = neobundle#get('vim-gitgutter')
if !empty(s:bundle)
    let g:gitgutter_sign_added = '✚'
    let g:gitgutter_sign_modified = '➜'
    let g:gitgutter_sign_removed = '✘'
endif
unlet s:bundle
" }}}

" Plugin : vim-pandoc ===================================== {{{
" https://github.com/vim-pandoc/vim-pandoc
let s:bundle = neobundle#get('vim-pandoc')
if !empty(s:bundle)
    let g:pandoc_no_folding = 1
    let g:pandoc_use_hard_wraps = 1
endif
unlet s:bundle
" }}}

" Plugin : vim-rooter ===================================== {{{
" https://github.com/airblade/vim-rooter
let s:bundle = neobundle#get('vim-rooter')
if !empty(s:bundle)
    augroup myRooter
        autocmd!
        " 2013/05/24 プラグイン本体に含まれていないもの。
        autocmd BufEnter *.hs,*.pl,*.pm,*.psgi,*.t :Rooter
    augroup END
    let g:rooter_use_lcd = 1
endif
unlet s:bundle
" }}}

" Kwbd
" バッファを削除してもウィンドウのレイアウトを崩さない
" http://nanasi.jp/articles/vim/kwbd_vim.html
command! Kwbd let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn

" Plugin : vim-colors-solarized =========================== {{{
let s:bundle = neobundle#get('vim-colors-solarized')
if !empty(s:bundle)
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
endif
unlet s:bundle
" }}}

" Plugun : unite.vim ====================================== {{{
" https://github.com/Shougo/unite.vim
" http://d.hatena.ne.jp/ruedap/20110110/vim_unite_plugin
" http://d.hatena.ne.jp/ruedap/20110117/vim_unite_plugin_1_week
let s:bundle = neobundle#get('unite.vim')
function! s:bundle.hooks.on_source(bundle)
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
unlet s:bundle
" }}}

" Plugin ================================================== {{{
" lightline.vim, powerlineが共に無効である時の設定。
if empty(neobundle#get('lightline.vim')) || empty(neobundle#get('powerline'))
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
        autocmd FileType perl nnoremap <buffer> [perl]t  :%!perltidy<CR>
        autocmd FileType perl vnoremap [perl]   <Nop>
        autocmd FileType perl vmap     <Space>p [perl]
        autocmd FileType perl vnoremap <buffer> [perl]t :!perltidy<CR>
    augroup END
endif
" }}}

" Python (File Type) ====================================== {{{
if has('autocmd')
	augroup EditPython
		autocmd!
		autocmd FileType python set expandtab
		autocmd FileType python set smarttab
		autocmd FileType python set omnifunc=pythoncomplete#Complete
		" http://vim.sourceforge.net/scripts/script.php?script_id=30
		" autocmd FileType python source $HOME/.vim/plugin/python.vim
	augroup END
endif

" PythonTidy
" http://cheeseshop.python.org/pypi/PythonTidy/
map ,yt <ESC>:%! pythontidy<CR>
map ,ytv <ESC>:%'<, '>! pythontidy<CR>
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

" XHTML (File Type) ======================================= {{{
" ':h ft-xhtml-omni' を参照
if has('autocmd')
	augroup EditHTML
		autocmd!
    autocmd BufRead,BufNewFile *.ep   set filetype=html
		autocmd BufRead,BufNewFile *.tmpl set filetype=html
		autocmd FileType html set expandtab
		autocmd FileType html set shiftwidth=2
		autocmd FileType html set smarttab
		autocmd FileType html set softtabstop=2
		autocmd FileType html set tabstop=2
		autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
		set expandtab
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
