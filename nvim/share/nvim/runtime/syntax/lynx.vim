" Vim syntax file
" Language:	Lynx Web Browser Configuration (lynx.cfg)
" Maintainer:	Doug Kearns <dougkearns@gmail.com>
" Last Change:	2023 Nov 09

" Lynx 2.8.9

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match lynxStart "^" skipwhite nextgroup=lynxOption

syn match lynxComment "\%(^\|\s\+\)#.*" contains=lynxTodo

syn keyword lynxTodo TODO NOTE FIXME XXX contained

syn match lynxDelimiter ":" skipwhite nextgroup=lynxBoolean,lynxHttpProtocol,lynxNumber,lynxNone,lynxRCOption

syn case ignore
syn keyword lynxBoolean TRUE FALSE ON OFF contained
syn keyword lynxNone	NONE		  contained
syn case match

syn match lynxNumber	   "-\=\<\d\+\>" contained
syn match lynxHttpProtocol "\<1\.[01]\>" contained

"{{{ Options
syn case ignore
syn keyword lynxOption ACCEPT_ALL_COOKIES ALERTSECS
	\ ALWAYS_RESUBMIT_POSTS ALWAYS_TRUSTED_EXEC ANONFTP_PASSWORD
	\ ASSUMED_COLOR ASSUMED_DOC_CHARSET_CHOICE ASSUME_CHARSET
	\ ASSUME_LOCAL_CHARSET ASSUME_UNREC_CHARSET AUTO_SESSION
	\ AUTO_UNCACHE_DIRLISTS BAD_HTML BIBP_BIBHOST BIBP_GLOBAL_SERVER
	\ BLOCK_MULTI_BOOKMARKS BOLD_H1 BOLD_HEADERS BOLD_NAME_ANCHORS
	\ BOOKMARK_FILE BROKEN_FTP_EPSV BROKEN_FTP_RETR BZIP2_PATH
	\ CASE_SENSITIVE_ALWAYS_ON CASE_SENSITIVE_SEARCHING CHARACTER_SET
	\ CHARSETS_DIRECTORY CHARSET_SWITCH_RULES CHECKMAIL CHMOD_PATH
	\ COLLAPSE_BR_TAGS COLOR COLOR_STYLE COMPRESS_PATH CONNECT_TIMEOUT
	\ COOKIE_ACCEPT_DOMAINS COOKIE_FILE COOKIE_LOOSE_INVALID_DOMAINS
	\ COOKIE_QUERY_INVALID_DOMAINS COOKIE_REJECT_DOMAINS COOKIE_SAVE_FILE
	\ COOKIE_STRICT_INVALID_DOMAINS COPY_PATH CSO_PROXY CSWING_PATH
	\ DEBUGSECS DEFAULT_BOOKMARK_FILE DEFAULT_CACHE_SIZE DEFAULT_COLORS
	\ DEFAULT_EDITOR DEFAULT_INDEX_FILE DEFAULT_KEYPAD_MODE
	\ DEFAULT_KEYPAD_MODE_IS_NUMBERS_AS_ARROWS DEFAULT_USER_MODE
	\ DEFAULT_VIRTUAL_MEMORY_SIZE DELAYSECS DIRED_MENU DIR_LIST_ORDER
	\ DIR_LIST_STYLE DISPLAY DISPLAY_CHARSET_CHOICE DOWNLOADER EMACS_KEYS
	\ EMACS_KEYS_ALWAYS_ON ENABLE_LYNXRC ENABLE_SCROLLBACK EXTERNAL
	\ FILE_EDITOR FILE_SORTING_METHOD FINGER_PROXY FOCUS_WINDOW
	\ FORCE_8BIT_TOUPPER FORCE_COOKIE_PROMPT FORCE_EMPTY_HREFLESS_A
	\ FORCE_SSL_COOKIES_SECURE FORCE_SSL_PROMPT FORMS_OPTIONS FTP_FORMAT
	\ FTP_PASSIVE FTP_PROXY GLOBAL_EXTENSION_MAP GLOBAL_MAILCAP
	\ GOPHER_PROXY GOTOBUFFER GZIP_PATH HELPFILE HIDDEN_LINK_MARKER
	\ HISTORICAL_COMMENTS HTMLSRC_ATTRNAME_XFORM HTMLSRC_TAGNAME_XFORM
	\ HTTPS_PROXY HTTP_PROXY INCLUDE INFLATE_PATH INFOSECS INSTALL_PATH
	\ JUMPBUFFER JUMPFILE JUMP_PROMPT JUSTIFY JUSTIFY_MAX_VOID_PERCENT
	\ KBLAYOUT KEYBOARD_LAYOUT KEYMAP KEYPAD_MODE
	\ LEFTARROW_IN_TEXTFIELD_PROMPT LINEEDIT_MODE LIST_FORMAT
	\ LIST_NEWS_DATES LIST_NEWS_NUMBERS LOCALE_CHARSET LOCALHOST_ALIAS
	\ LOCAL_DOMAIN LOCAL_EXECUTION_LINKS_ALWAYS_ON
	\ LOCAL_EXECUTION_LINKS_ON_BUT_NOT_REMOTE LYNXCGI_DOCUMENT_ROOT
	\ LYNXCGI_ENVIRONMENT LYNX_HOST_NAME LYNX_SIG_FILE MAIL_ADRS
	\ MAIL_SYSTEM_ERROR_LOGGING MAKE_LINKS_FOR_ALL_IMAGES
	\ MAKE_PSEUDO_ALTS_FOR_INLINES MAX_COOKIES_BUFFER MAX_COOKIES_DOMAIN
	\ MAX_COOKIES_GLOBAL MESSAGESECS MINIMAL_COMMENTS MKDIR_PATH
	\ MULTI_BOOKMARK MULTI_BOOKMARK_SUPPORT MV_PATH NCR_IN_BOOKMARKS
	\ NESTED_TABLES NEWSPOST_PROXY NEWSREPLY_PROXY NEWS_CHUNK_SIZE
	\ NEWS_MAX_CHUNK NEWS_POSTING NEWS_PROXY NNTPSERVER NNTP_PROXY
	\ NONRESTARTING_SIGWINCH NO_DOT_FILES NO_FILE_REFERER
	\ NO_FORCED_CORE_DUMP NO_FROM_HEADER NO_ISMAP_IF_USEMAP NO_MARGINS
	\ NO_PAUSE NO_PROXY NO_REFERER_HEADER NO_TABLE_CENTER NO_TITLE
	\ NUMBER_FIELDS_ON_LEFT NUMBER_LINKS_ON_LEFT OUTGOING_MAIL_CHARSET
	\ PARTIAL PARTIAL_THRES PERSISTENT_COOKIES PERSONAL_EXTENSION_MAP
	\ PERSONAL_MAILCAP PERSONAL_MAIL_ADDRESS POSITIONABLE_EDITOR
	\ PREFERRED_CHARSET PREFERRED_ENCODING PREFERRED_LANGUAGE
	\ PREFERRED_MEDIA_TYPES PREPEND_BASE_TO_SOURCE
	\ PREPEND_CHARSET_TO_SOURCE PRETTYSRC PRETTYSRC_SPEC
	\ PRETTYSRC_VIEW_NO_ANCHOR_NUMBERING PRINTER QUIT_DEFAULT_YES RAW_MODE
	\ READ_TIMEOUT REFERER_WITH_QUERY REPLAYSECS REUSE_TEMPFILES
	\ RLOGIN_PATH RM_PATH RMDIR_PATH RULE RULESFILE
	\ RUN_ALL_EXECUTION_LINKS RUN_EXECUTION_LINKS_LOCAL SAVE_SPACE
	\ SCAN_FOR_BURIED_NEWS_REFS SCREEN_SIZE SCROLLBAR SCROLLBAR_ARROW
	\ SEEK_FRAG_AREA_IN_CUR SEEK_FRAG_MAP_IN_CUR SELECT_POPUPS
	\ SEND_USERAGENT SESSION_FILE SESSION_LIMIT SET_COOKIES SETFONT_PATH
	\ SHOW_COLOR SHOW_CURSOR SHOW_DOTFILES SHOW_KB_NAME SHOW_KB_RATE
	\ SNEWSPOST_PROXY SNEWSREPLY_PROXY SNEWS_PROXY SOFT_DQUOTES
	\ SOURCE_CACHE SOURCE_CACHE_FOR_ABORTED SSL_CERT_FILE STARTFILE
	\ STATUS_BUFFER_SIZE STRIP_DOTDOT_URLS SUBSTITUTE_UNDERSCORES
	\ SUB_BOOKMARKS SUFFIX SUFFIX_ORDER SYSLOG_REQUESTED_URLS SYSLOG_TEXT
	\ SYSTEM_EDITOR SYSTEM_MAIL SYSTEM_MAIL_FLAGS TAGSOUP TAR_PATH
	\ TELNET_PATH TEXTFIELDS_NEED_ACTIVATION TIMEOUT TN3270_PATH
	\ TOUCH_PATH TRIM_INPUT_FIELDS TRUSTED_EXEC TRUSTED_LYNXCGI
	\ UNCOMPRESS_PATH UNDERLINE_LINKS UNZIP_PATH UPLOADER
	\ URL_DOMAIN_PREFIXES URL_DOMAIN_SUFFIXES USERAGENT USER_MODE
	\ USE_FIXED_RECORDS USE_MOUSE USE_SELECT_POPUPS UUDECODE_PATH
	\ VERBOSE_IMAGES VIEWER VISITED_LINKS VI_KEYS VI_KEYS_ALWAYS_ON
	\ WAIS_PROXY XHTML_PARSING XLOADIMAGE_COMMAND ZCAT_PATH ZIP_PATH
	\ TRIM_BLANK_LINES GUESS_SCHEME HTTP_PROTOCOL HTML5_CHARSETS
	\ TRIM_BLANK_LINES PREFERRED_CONTENT_TYPE SSL_CLIENT_CERT_FILE
	\ SSL_CLIENT_KEY_FILE MAX_URI_SIZE UNIQUE_URLS MESSAGE_LANGUAGE
	\ CONV_JISX0201KANA WAIT_VIEWER_TERMINATION BLAT_MAIL ALT_BLAT_MAIL
	\ DONT_WRAP_PRE TRACK_INTERNAL_LINKS FORCE_HTML HIDDENLINKS SHORT_URL
	\ LISTONLY LIST_INLINE LOCALHOST WITH_BACKSPACES
	\ contained nextgroup=lynxDelimiter
syn keyword lynxRCOption accept_all_cookies assume_charset auto_session
	\ bookmark_file case_sensitive_searching character_set
	\ collapse_br_tags cookie_accept_domains cookie_file
	\ cookie_loose_invalid_domains cookie_query_invalid_domains
	\ cookie_reject_domains cookie_strict_invalid_domain
	\ cookie_strict_invalid_domains dir_list_style display emacs_keys
	\ file_editor file_sorting_method force_cookie_prompt force_ssl_prompt
	\ ftp_passive html5_charsets http_protocol kblayout keypad_mode
	\ lineedit_mode locale_charset make_links_for_all_images
	\ make_pseudo_alts_for_inlines multi_bookmark no_pause
	\ personal_mail_address preferred_charset preferred_encoding
	\ preferred_language preferred_media_types raw_mode
	\ run_all_execution_links run_execution_links_local
	\ run_execution_links_on_local_files scrollbar select_popups
	\ send_useragent session_file set_cookies show_color show_cursor
	\ show_dotfiles show_kb_rate sub_bookmarks tagsoup underline_links
	\ useragent user_mode verbose_images vi_keys visited_links
	\ contained nextgroup=lynxDelimiter
syn case match
" }}}

" cfg2html.pl formatting directives
syn match lynxFormatDir  "^\.h\d\s.*$"
syn match lynxFormatDir  "^\.\%(ex\|nf\)\%(\s\+\d\+\)\=$"
syn match lynxFormatDir  "^\.fi$"
syn match lynxFormatDir  "^\.url\>"

hi def link lynxBoolean		Boolean
hi def link lynxComment		Comment
hi def link lynxDelimiter	Special
hi def link lynxFormatDir	Special
hi def link lynxHttpProtocol	Constant
hi def link lynxNone		Constant
hi def link lynxNumber		Number
hi def link lynxOption		Identifier
hi def link lynxRCOption	lynxOption
hi def link lynxTodo		Todo

let b:current_syntax = "lynx"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8 noet fdm=marker:
