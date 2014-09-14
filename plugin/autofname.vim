" vi:set ts=8 sts=2 sw=2 tw=0:
"
" autofname.vim - A plugin to update time stamps automatically
"
" Maintainer:	MURAOKA Taro <koron@tka.att.ne.jp>
" Last Change:	15-Sep-2014.

" Description:
" Command:
"   :Autofname	    Manually autofname.
"   :AutofnameON	    Turn on autofname in current buffer (default).
"   :AutofnameOFF    Turn off autofname in current buffer.
"
" Options:
"   Each global variable (option) is overruled by buffer variable (what
"   starts with "b:").
"
"   'autofname_format'
"	Format string used for time stamps.  See |strftime()| for details.
"	See MonthnameString() for special extension of format.
"	Default: '%d-%3m-%Y'
"
"   'autofname_lines'
"	The number of lines searched for the existence of a time stamp when
"	writing a buffer.  The search range will be from top of buffer (or
"	line 'autofname_start_line') to 'autofname_lines' lines below.  The
"	bigger value you have, the longer it'll take to search words.  You
"	can expect to improve performance by decreasing the value of this
"	option.
"	Default: 50
"
"   'autofname_start_line'
"	Line number to start searching for time stamps when writing buffer
"	to file.
"	If minus, line number is counted from the end of file.
"	Default: 1
"
"   'autofname_keyword_pre'
"	A prefix pattern (see |pattern| for details) which denotes time
"	stamp's location.  If empty, default value will be used.
"	Default: '(File name:'
"
"   'autofname_keyword_post'
"	A postfix pattern which denotes time stamp's location.  If empty,
"	default value will be used.
"	Default: ')'
"
" Usage:
"   Write a line as below (case ignored) somewhere in the first 50 lines of
"   a buffer:
"	Last Change: .
"   When writing the buffer to a file, this line will be modified and a time
"   stamp will be inserted automatically.  Example:
"	Last Change: 11-May-2002.
"
"   You can execute :Autofname command to update time stamps manually.  The
"   range of lines which looks for a time stamp can also be specified.  When
"   no range is given, the command will be applied to the current line.
"   Example:
"	:%Autofname		" Whole file
"	:\<,\>Autofname		" Range selected by visual mode
"	:Autofname		" Current cursor line
"
"   The format of the time stamp to insert can be specified by
"   'autofname_format' option.  See |strftime()| (vim script function) for
"   details.  Sample format settings and the corresponding outputs are show
"   below.
"	FORMAT: %Y/%m/%d	OUTPUT: 2001/12/24
"	FORMAT: %H:%M:%S	OUTPUT: 10:06:32
"	FORMAT: %y%m%d-%H%M	OUTPUT: 011224-1006
"
"   Autofname.vim determines where to insert a time stamp by looking for a
"   KEYWORD.  A keyword consists of a PREFIX and a POSTFIX part, and they
"   can be set by 'autofname_keyword_pre' and 'autofname_keyword_post'
"   options, respectively.  If you set these values as below in your .vimrc:
"	:let autofname_format = ': %Y/%m/%d %H:%M:%S '
"	:let autofname_keyword_pre  = '\$Date'
"	:let autofname_keyword_post = '\$'
"   They will function like $Date$ in cvs.  Example:
"	$Date: 2001/12/24 10:06:32 $
"
"   Just another application. To insert a time stamp between '<!--DATE-->'
"   when writing HTML, try below:
"	:let b:autofname_keyword_pre = '<!--DATE-->'
"	:let b:autofname_keyword_post = '<!--DATE-->'
"   It will be useful if to put these lines in your ftplugin/html.vim.
"   Example:
"	<!--DATE-->24-Dec-2001<!--DATE-->
"
"   In addition, priority is given to a buffer local option (what starts in
"   b:) about all the options of autofname.
"
"
" To make vim NOT TO LOAD this plugin, write next line in your .vimrc:
"	:let plugin_autofname_disable = 1

" Japanese Description:
" �R�}���h:
"   :Autofname	    �蓮�Ń^�C���X�^���v�X�V
"   :AutofnameON	    ���݂̃o�b�t�@�̎����X�V��L����
"   :AutofnameOFF    ���݂̃o�b�t�@�̎����X�V�𖳌���
"
" �I�v�V����: (���ꂼ��̃I�v�V�����̓o�b�t�@��(b:)���D�悳���)
"
"   'autofname_format'
"	�^�C���X�^���v�Ɏg�p�����t�H�[�}�b�g������B�t�H�[�}�b�g�̏ڍׂ�
"	|strftime()|���Q�ƁB�t�H�[�}�b�g�ւ̓Ǝ��g���ɂ��Ă�MonthnameString()
"	���Q�ƁB�ȗ��l: '%d-%3m-%Y'
"
"   'autofname_lines'
"	�ۑ����Ƀ^�C���X�^���v�̑��݂��`�F�b�N����s���B���₹�Α��₷�ق�
"	�L�[���[�h���������邽�߂Ɏ��Ԃ������蓮�삪�x���Ȃ�B�t�ɒx���Ɗ���
"	���Ƃ��ɂ͏����Ȓl��ݒ肷��΃p�t�H�[�}���X�̉��P�����҂ł���B
"	�ȗ��l: 50
"
"   'autofname_keyword_pre'
"	�^�C���X�^���v�̑��݂������O�u�L�[���[�h(���K�\��)�B�K�{�B�󕶎����
"	�w�肷��Əȗ��l���g����B�ȗ��l: '(File name:'
"
"   'autofname_keyword_post'
"	�^�C���X�^���v�̑��݂�������u�L�[���[�h(���K�\��)�B�K�{�B�󕶎����
"	�w�肷��Əȗ��l���g����B�ȗ��l: ')'
"
" �g�p�@:
"   �t�@�C���̐擪����50�s�ȓ���
"	Last Change: .
"   �Ə������s(�啶���������͋�ʂ��܂���)��p�ӂ���ƁA�t�@�C���̕ۑ�(:w)��
"   �Ɏ����I�ɂ��̎���(�^�C���X�^���v)���}������܂��B���ʗ�:
"	Last Change: 11-May-2002.
"
"   Ex�R�}���h��:Autofname�����s���邱�ƂŎ蓮�Ń^�C���X�^���v�̍X�V���s�Ȃ�
"   �܂��B���̍ۂɃ^�C���X�^���v��T���͈͂��w�肷�邱�Ƃ��ł��܂��B���ɔ͈�
"   ���w�肵�Ȃ���΃J�[�\���̂���s���ΏۂɂȂ�܂��B��:
"	:%Autofname		" �t�@�C���S��
"	:\<,\>Autofname		" �r�W���A���I��̈�
"	:Autofname		" ���݃J�[�\���̂���s
"
"   �}������^�C���X�^���v�̏����̓I�v�V����'autofname_format'�Ŏw�肷�邱��
"   ���ł��܂��B�ڍׂ�Vim�X�N���v�g�֐�|strftime()|�̐����ɏ]���܂��B�ȉ���
"   �����Ƃ��̏o�̗͂�������܂�:
"	����: %Y/%m/%d		�o��: 2001/12/24
"	����: %H:%M:%S		�o��: 10:06:32
"	����: %y%m%d-%H%M	�o��: 011224-1006
"
"   autofname.vim�̓L�[���[�h��T�����ƂŃ^�C���X�^���v��}�����ׂ��ʒu������
"   ���Ă��܂��B�L�[���[�h�͑O�u���ƌ�u������Ȃ�A���ꂼ��I�v�V������
"   'autofname_keyword_pre'��'autofname_keyword_post'��ݒ肷�邱�ƂŕύX�ł�
"   �܂��B�l�ݒ�t�@�C��(_vimrc)�Ŏ��̂悤�ɐݒ肷���:
"	:let autofname_format = ': %Y/%m/%d %H:%M:%S '
"	:let autofname_keyword_pre  = '\$Date'
"	:let autofname_keyword_post = '\$'
"   cvs�ɂ�����$Date$�̂悤�ɓ��삵�܂��B��:
"	$Date: 2001/12/24 10:06:32 $
"
"   ���p�Ƃ���HTML���L�q����ۂ�<!--DATE-->�ň͂܂ꂽ���Ƀ^�C���X�^���v��}
"   �����������ꍇ�ɂ�:
"	:let b:autofname_keyword_pre = '<!--DATE-->'
"	:let b:autofname_keyword_post = '<!--DATE-->'
"   �Ǝw�肵�܂��Bftplugin/html.vim�Őݒ肷��ƕ֗��ł��傤�B��:
"	<!--DATE-->24-Dec-2001<!--DATE-->
"
"   �Ȃ�autofname�̑��ẴI�v�V�����ɂ��āA�o�b�t�@���[�J���I�v�V����(b:��
"   �n�܂����)���D�悳��܂��B
"
" ���̃v���O�C����Ǎ��݂����Ȃ�����.vimrc�Ɏ��̂悤�ɏ�������:
"	:let plugin_autofname_disable = 1

if exists('plugin_autofname_disable')
  finish
endif
let s:debug = 0

"---------------------------------------------------------------------------
"				    Options

"
" 'autofname_format'
"
if !exists('autofname_format')
  let g:autofname_format = '%d-%3m-%Y'
endif

"
" 'autofname_lines'
"
if !exists('autofname_lines')
  let g:autofname_lines = 50
endif

"
" 'autofname_start_line'
"
if !exists('autofname_start_line')
  let g:autofname_start_line = 1
endif

"
" 'autofname_keyword_pre'
"
if !exists('autofname_keyword_pre')
  let g:autofname_keyword_pre = '(File name:'
endif

"
" 'autofname_keyword_post'
"
if !exists('autofname_keyword_post')
  let g:autofname_keyword_post = ')'
endif

"---------------------------------------------------------------------------
"				    Mappings

command! -range Autofname call <SID>Autofname(<line1>, <line2>)
command! AutofnameOFF let b:autofname_disable = 1
command! AutofnameON let b:autofname_disable = 0
if has("autocmd")
  augroup Autofname
    au!
    autocmd BufUnload,FileWritePre,BufWritePre * call <SID>Autofname()
  augroup END
endif " has("autocmd")

"---------------------------------------------------------------------------
"				 Implementation

"
" Autofname([{firstline} [, {lastline}]])
"
"   {firstline}��{lastline}�Ŏw�肳�ꂽ�͈͂ɂ��āA�^�C���X�^���v�̎���
"   �A�b�v�f�[�g���s�Ȃ��B{firstline}���ȗ����ꂽ�ꍇ�̓t�@�C���̐擪�A
"   {lastline}���ȗ����ꂽ�ꍇ��{firstline}����'autofname_lines'�s�͈̔͂���
"   �ۂɂȂ�B
"
function! s:Autofname(...)
  " Check enable
  if (exists('b:autofname_disable') && b:autofname_disable != 0) || &modified == 0
    return
  endif

  " Verify {firstline}
  if a:0 > 0 && a:1 > 0
    let firstline = a:1
  else
    let firstline = s:GetAutofnameStartLine()
  endif

  " Verify {lastline}
  if a:0 > 1 && a:2 <= line('$')
    let lastline = a:2
  else
    let lastline = firstline + s:GetAutofnameLines() - 1
    " Range check
    if lastline > line('$')
      let lastline = line('$')
    endif
  endif

  if firstline <= lastline
    call s:AutofnameStub(firstline, lastline)
  endif
endfunction

"
" GetAutofnameStartLine()
"
"   �T���J�n�_���擾����
"
function! s:GetAutofnameStartLine()
  let retval = 1
  if exists('b:autofname_start_line')
    let retval = b:autofname_start_line
  elseif exists('g:autofname_start_line')
    let retval = g:autofname_start_line
  endif

  if retval < 0
    let retval = retval + line('$') + 1
  endif
  if retval <= 0
    let retval = 1
  endif
  return retval
endfunction

"
" GetAutofnameLines()
"   
"   autofname�Ώ۔͈͂��擾����
"
function! s:GetAutofnameLines()
  if exists('b:autofname_lines') && b:autofname_lines > 0
    return b:autofname_lines
  elseif exists('g:autofname_lines') && g:autofname_lines > 0
    return g:autofname_lines
  else
    return 50
  endif
endfunction

"
" AutofnameStub(first, last)
"
"   �w�肳�ꂽ�͈͂ɂ��ă^�C���X�^���v�̎����A�b�v�f�[�g���s�Ȃ��B
"
function! s:AutofnameStub(first, last)

  " Verify pre-keyword.
  if exists('b:autofname_keyword_pre') && b:autofname_keyword_pre != ''
    let pre = b:autofname_keyword_pre
  else
    if exists('g:autofname_keyword_pre') && g:autofname_keyword_pre != ''
      let pre = g:autofname_keyword_pre
    else
      let pre = '\cLast Change:'
    endif
  endif

  " Verify post-keyword.
  if exists('b:autofname_keyword_post') && b:autofname_keyword_post != ''
    let post = b:autofname_keyword_post
  else
    if exists('g:autofname_keyword_post') && g:autofname_keyword_post != ''
      let post = g:autofname_keyword_post
    else
      let post = '\.'
    endif
  endif

  " Verify format.
  if exists('b:autofname_format') && b:autofname_format != ''
    let format = b:autofname_format
  else
    if exists('g:autofname_format') && g:autofname_format != ''
      let format = g:autofname_format
    else
      let format = '%d-%3m-%Y'
    endif
  endif

  " Generate substitution pattern
  let pat = '\('.pre.'\s*\)\(\S.*\)\?\('.post.'\)'
  " let sub = Strftime2(format)
  let sub = expand("%:t")
  " For debug
  if s:debug
    echo "range=".a:first."-".a:last
    echo "pat= ".pat
    echo "sub= ".sub
  endif

  " Process
  let i = a:first
  while i <= a:last
    let curline = getline(i)
    if curline =~ pat
      let newline = substitute(curline, pat, '\1' . sub . '\3', '')
      if curline !=# newline
	call setline(i, newline)
      endif
    endif
    let i = i + 1
  endwhile
endfunction

"
" Strftime2({format} [, {time}])
"   Enchanced version of strftime().
"
"   strftime()�̃t�H�[�}�b�g�g���o�[�W�����B�t�H�[�}�b�g�����͂قƂ�ǃI���W
"   �i���ƈꏏ�B���������̉p�ꖼ�ɒu�������ʂȏ��� %{n}m ���g�p�\�B{n}��
"   �͉p�ꖼ�̕�����̒������w�肷��(�ő�9)�B0���w�肷��Η]���ȋ󔒂͕t����
"   ��Ȃ��B
"	��:
"	    :echo Strftime2("%d-%3m-%Y")
"	    07-Oct-2001
"	    :echo Strftime2("%d-%0m-%Y")
"	    07-October-2001
"
function! Strftime2(...)
  if a:0 > 0
    " Get {time} argument.
    if a:0 > 1
      let time = a:2
    else
      let time = localtime()
    endif
    " Parse special format.
    let format = a:1
    let format = substitute(format, '%\(\d\+\)m', '\=MonthnameString(-1, submatch(1), time)', 'g')
    let format = substitute(format, '%\(\d\+\)a', '\=DaynameString(-1, submatch(1), time)', 'g')
    return strftime(format, time)
  endif
  " Genrate error!
  return strftime()
endfunction

"
" MonthnameString([{month} [, {length} [, {time}]]])
"   Get month name string in English with first specified letters.
"
"   �p��̌������w�肵�������ŕԂ��B{month}���ȗ������ꍇ�ɂ͌��݂̌�������
"   �����B{month}�ɖ����Ȏw��(1�`12�ȊO)���s�Ȃ�ꂽ�ꍇ��{time}�Ŏ������
"   �������Ԃ����B{time}���ȗ������ꍇ�ɂ͑����|localtime()|���g�p����
"   ��B{length}�ɂ͕Ԃ����O�̒������w�肷�邪�ȗ�����ƔC�Ӓ��ɂȂ�B
"	��:
"	    :echo MonthnameString(8) . " 2001"
"	    August 2001
"	    :echo MonthnameString(8,3) . " 2001"
"	    Aug 2001
"
function! MonthnameString(...)
  " Get {time} argument.
  if a:0 > 2
    let time = a:3
  else
    let time = localtime()
  endif
  " Verify {month}.
  if a:0 > 0 && (a:1 >= 1 && a:1 <= 12)
    let month = a:1
  else
    let month = substitute(strftime('%m', time), '^0\+', '', '')
  endif
  " Verify {length}.
  if a:0 > 1 && (a:2 >= 1 && a:2 <= 9)
    let length = a:2
  else
    let length = strpart('785534469788', month - 1, 1)
  endif
  " Generate string of month name.
  return strpart('January  February March    April    May      June     July     August   SeptemberOctober  November December ', month * 9 - 9, length)
endfunction

"
" DaynameString([{month} [, {length} [, {time}]]])
"   Get day name string in English with first specified letters.
"
"   �p��̗j�������w�肵�������ŕԂ��B{day}���ȗ������ꍇ�ɂ͖{���̗j������
"   �Ԃ����B{day}�ɖ����Ȏw��(0�`6�ȊO)���s�Ȃ�ꂽ�ꍇ��{time}�Ŏ������
"   �j�������Ԃ����B{time}���ȗ������ꍇ�ɂ͑����|localtime()|���g�p��
"   ���B{length}�ɂ͕Ԃ����O�̒������w�肷�邪�ȗ�����ƔC�Ӓ��ɂȂ�B
"	��:
"	    :echo DaynameString(0)
"	    Sunday
"	    :echo DaynameString(5,3).', 13th'
"	    Fri, 13th
"
function! DaynameString(...)
  " Get {time} argument.
  if a:0 > 2
    let time = a:3
  else
    let time = localtime()
  endif
  " Verify {day}.
  if a:0 > 0 && (a:1 >= 0 && a:1 <= 6)
    let day = a:1
  else
    let day = strftime('%w', time) + 0
  endif
  " Verify {length}.
  if a:0 > 1 && (a:2 >= 1 && a:2 <= 9)
    let length = a:2
  else
    let length = strpart('6798686', day, 1)
  endif
  " Generate string of day name.
  return strpart('Sunday   Monday   Tuesday  WednesdayThursday Friday   Saturday ', day * 9, length)
endfunction
