" Vim compiler file
" Compiler:	any compiler run from make -- for win32-Vim & Cygwin  {{{1
" Maintainer:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" URL: http://hermitte.free.fr/vim/ressources/vimfiles/compiler/cygwin.vim
" Last Change:	29th May 2004
"
" Note: This file is useful with gcc and other programs run from make, when
" these tools come from Cygwin and the version of Vim used is the win32 native
" version.
" In other environments, Vim default settings are perfect.
"
" Reason: the filenames (for whom GCC reports errors) are expressed in the
" UNIX form, and Vim is unable to open them from the quickfix window. Hence
" the filtering used to replace '/' (root) by {cygpath -m /}.
"
" In order to correctly recognize Cygwin, $TERM or $OSTYPE should value
" "cygwin".
"
" Tested With:	Cygwin + vim-win32 on a MsWindows XP box.
" }}}1
" ======================================================================
" Initializations                                          {{{1

" Check we are using cygwin                 {{{2
if !has('win32') || !( ($TERM=='cygwin') || ($OSTYPE=='cygwin') )
  echoerr "Cygwin not detected..."
  finish
endif

" Update the value for the current compiler {{{2
if     exists('current_compiler')   | let s:cp =   current_compiler
elseif exists('b:current_compiler') | let s:cp = b:current_compiler
else                                | let s:cp = ''
endif

if s:cp != ''
  if b:current_compiler =~ 'cygwin$'
    finish
  else
    let b:current_compiler = s:cp . '_cygwin'
  endif
else
  let b:current_compiler = "make_cygwin"
endif

" }}}1
" ======================================================================
" New version, requires Perl.                              {{{1
" Tested with Cygwin's Perl 5.8.2.
" a- emplacement of the perl filter
let s:file = substitute(expand('<sfile>:p:h'), ' ', '\\ ', 'g')
" b- filter to apply over `make' outputs: '/' --> {root}
let &l:makeprg = "make $* 2>&1 \\| ".s:file."/cygwin.pl"
" c- default value for 'efm'
" setlocal efm&

" }}}1
" ======================================================================
" Old way using sed ; not able to follow symbolic links    {{{1
finish 
" a- emplacement of the root path 
" let root = matchstr(system('cygpath -'. (has('win95') ? 'd' : 'w') . ' /'), "^.*\\ze\n") . '/'
let s:root = matchstr(system('cygpath -m /'), "^.*\\ze\n") . '/'
"
" b- filter to apply over `make' outputs: '/' --> {root}
" let &l:makeprg = "make $* 2>&1 \\| sed 'sK^ */.*:[0-9]*:K".s:root."&Kg'"

" c- default value for 'efm'
" setlocal efm&


" }}}1
" ======================================================================
" The following functions do not work as expected.         {{{1
finish 
" The buffer is correctly modified, but unfortunatelly, Vim has already
" memorised the pathnames it received from :make.
function! s:ConvertPath(path)
  let path = a:path
  " call system('test -h '.path)
  call confirm(path, '&Ok', 1)
  " if v:shell_error == 0 " true
    let path = system('realpath '.path)
    call confirm(path, '&Ok', 1)
  " endif
  return substitute(path, '/cygdrive/\(.\)', '\u\1:', '')
  " return substitute(path, '^ */.*', s:root.'&', '')
endfunction

function! s:CheckPaths()
  set modifiable
  %s#^ */.*\ze|\d*|#\=s:ConvertPath(submatch(0))#
  set nomodifiable
endfunction

augroup QF
  au!
  au BufReadPost quickfix silent call <sid>CheckPaths()
augroup END

" }}}1
" ======================================================================
" Changelog                                                {{{1
" 13th Feb 2004:   {{{2
"   Do not try to convert non absolute pathes
" 29th May 2004:   {{{2
"   Unfortunate attempt to fix pathnames thanks to an autocommand binded to
"   quickfix buffer (Idea stolen from Hari Krishna Dara) : the pathnames must
"   be converted before Vim read them. Otherwise it will not be able to jump
"   into the right file.
"   Thus a perl script {rtp}/compiler/cygwin.pl has been defined. It converts
"   Cygwin pathnames into MsWindows pathnames, and follows symbolic links as
"   well.
" }}}1
" ======================================================================
" vim600: set foldmethod=marker:
