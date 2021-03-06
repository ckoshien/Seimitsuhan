#include "hspda.as"

#define	ver			"0.647"
#define	build		"(build20150730)"
#define	seimituhan	"<a href=\"http:\/\/hp.ckoshien.client.jp\/contents\/ranbat.html\">精密はんII v"+ver+"<\/a><br>"
#define	DAM			"<a href=\"http:\/\/www.clubdam.com\/app\/damStation\/clubdamRanking.do?requestNo="

;UTF-8 URLエンコードモジュール
#module "encodemod"
#const global CODEPAGE_S_JIS            932 ; Shift-JIS
#const global CODEPAGE_EUC_JP         51932 ; EUC-JP
#const global CODEPAGE_JIS            50220 ; iso-2022-jp
#const global CODEPAGE_UTF_7          65000 ; utf-7
#const global CODEPAGE_UTF_8          65001 ; utf-8
#const global CODEPAGE_UNICODE         1200 ; Unicode
#const global CODEPAGE_UNICODE_BE      1201 ; Unicode(Big-Endian)
#const global CODEPAGE_AUTODET_ALL    50001 ; auto detect all
#const global CODEPAGE_AUTODET        50932 ; auto detect

#usecom IMultiLanguage@encodemod "{275c23e1-3747-11d0-9fea-00aa003f8646}" \
                                 "{275c23e2-3747-11d0-9fea-00aa003f8646}"
#comfunc MuLang_ConvertString  9 var, int, int, var, var, var, var
#deffunc encode_init
	newcom pMLang, IMultiLanguage
	return

#defcfunc encode var v1, int p1, var v2, int p2, local sSize, local dSize, local pdwMode
	pdwMode = 0
	sSize   = -1
	dSize   = 0
	sdim v2
	MuLang_ConvertString pMLang, pdwMode, p1, p2, v1, sSize, v2, dSize
	sdim v2, dSize
	MuLang_ConvertString pMLang, pdwMode, p1, p2, v1, sSize, v2, dSize
	return dSize

#deffunc encode_term
	delcom pMLang
	pMLang = 0
	return
#global

#define ctype range(%1, %2, %3) (%1 > %2 & %1 < %3)

;	encode_init
;	pStr = ""
;
;	sdim encbuf
;	repeat encode(pStr, CODEPAGE_S_JIS, dStr, CODEPAGE_UTF_8)
;		tmp = peek(dStr, cnt)
;		if range(tmp, 0x29, 0x3a) | range(tmp, 0x40, 0x5b) | range(tmp, 0x60, 0x7b) {
;			encbuf += strf("%c", tmp)
;		} else {
;			encbuf += strf("%%%02x", tmp)
;		}
;	loop
;	mes encbuf
#module
#const EXPAND_SIZE 2048
// 文字列の初期値を設定する
#deffunc set_string str str_to_set
    string_length = strlen(str_to_set)
    string_size = 64            // 測定のために公平化
    sdim string, string_size
    poke string, 0, str_to_set
    return

// 文字列を返す
#deffunc get_string var target
    target = string
    return

// 文字列の長さを返す
#defcfunc get_string_length
    return string_length

// 文字列を連結する
#deffunc add_string str str_to_add
    len = strlen(str_to_add)
    if string_size <= string_length + len {
        string_size += EXPAND_SIZE
        memexpand string, string_size
    }
    poke string, string_length, str_to_add
    string_length += len
    return
#global



;表示設定
	filename=""
	screen 0,640,240
	color 200,200,255
	boxf 0,0,640,240
	pos 10,13
	color 0,0,0
	font "",12
	titl="DAM精密採点(プラス)/Ⅱ/DX集計結果出力ツール「精密はんII」"+ver+build
	title titl

	mes "精密はん設定ファイル"
	pos 150,10
	input filename(0),300,20,0;オブジェクトid=0
	objsize 24,24
	pos 460,9
	button goto "...",*open_ini;オブジェクトid=1
	objsize 90,24
	pos 490,9
	button goto "入力データ設定",*ini_edit;オブジェクトid=2

	pos 10,40
	mes "出力ファイル"
	pos 150,40
	input filename(1),300,20,0;オブジェクトid=3
	objsize 24,24
	pos 460,39
	button goto "...",*file_save;オブジェクトid=4
	objsize 90,24
	pos 490,39
	combox ki,20,"HTML形式\nテキスト形式(未実装)\n";オブジェクトid=5
	objsize 100,24
	pos 490,60
	combox sor,20,"日付順(新→旧)\n日付順(旧→新)\n得点順\nリクエストNo.順\n曲名順\nアーティスト順\nビブラート長順\nしゃくり回数順\n音程順\nリズム順\n抑揚順\nこぶし回数順\nフォール回数順\n低音の上手さ順\n高音の上手さ順\nビブラートの上手さ順\nロングトーンの上手さ順\n";オブジェクトid=6
	pos 460,115
	mes "集計モード"
	objsize 100,24
	pos 460,130
	combox mode,20,"精密採点(プラス)\n精密採点Ⅱ\n精密採点DX\n";オブジェクトid=7
	objsize 60,60
	pos 460,160
	button goto "処理開始",*start;id=8
	stop

;==========================================================
*open_ini
	dialog "ini",16,"設定ファイルを開く"
	if stat=1 : filename(0)=refstr
	if stat!=1 : stop
	exist refstr
	alloc buf,strsize
	notesel buf
	if stat=1 : noteload refstr
	if stat!=1 : stop

;入力データファイル名取得
	for i,0,notemax,1
		noteget datafile(i),i;データファイル名の取得
	next
	objprm 0,filename(0)
	m=notemax;読み込むファイルの数
	stop

;=======================================
*file_save
	if ki==0:kin="html"
	if ki==1:kin="txt" 
	dialog kin,17,"保存先の選択"
	if stat=1 : filename(1)=refstr
	if stat!=1 : stop
	objprm 3,filename(1)
	stop
;=======================================
*ini_edit
	dialog "まだ実装していません。",0,""
	stop

;=====================================
*start
	if strlen(filename(1))<=4:dialog "出力ファイルを設定してください",1,"":goto *file_save
	;ファイルを開く
		ddim time,6
		time(0)=double(double(gettime(7))/1000+gettime(0)*365*30*3600*24+gettime(1)*30*3600*24+gettime(3)*3600*24+gettime(4)*3600+gettime(5)*60+gettime(6))
		id=0:cha=0:chb=0:x=0:a=0:bg=0:fl=0
		sdim tim1,100,1000
		sdim tim2,100,1000
		sdim tim3,100,1000
		sdim tim4,100,1000
		sdim tim5,100,1000
		sdim tim6,100,1000
		sdim no1,100,1000;リクエストNo
		sdim no2,100,1000;同上
		sdim art,100,1000;アーティスト		
		sdim son,100,1000;曲名
		ddim vib,1000    ;ビブラート長
		sdim vibt,100,1000;ビブタイプ
		sdim kob,100,1000;こぶし
		sdim fal,100,1000;フォール
		sdim sha,100,1000;しゃくり
		sdim mel,100,1000;音程
		sdim mell,100,1000;低音の上手さ
		sdim melh,100,1000;高音の上手さ
		sdim vibi,100,1000;ビブラートの上手さ
		sdim lont,100,1000;ロングトーンの上手さ
		sdim rhy,100,1000;リズム
		sdim yok,100,1000;抑揚
		dim dum1,1000
		dim dum2,1000
		dim dum3,1000
		dim dum4,1000
		dim dum5,1000
		dim dum6,1000
		dim n,id;n(cha)=元のインデックス
		ddim max_point,1000

	;精密採点DX用変数
	if mode==2 {
		sdim chstab,100,1000;チャート安定性
		sdim chexpress,100,1000;チャート表現力
		sdim chvib,100,1000;チャートビブラート
		sdim chrhy,100,1000;チャートリズム
		sdim hightess,100,1000;highTessitura
		sdim lowtess,100,1000;lowTessitura
		ddim avgtotal,1000	;全国平均点
		sdim avgpitch,100,1000;全国平均音程
		sdim avgstab,100,1000;全国平均安定性
		sdim avgexpress,100,1000;全国平均表現力
		sdim avgvib,100,1000;全国平均ビブラート
		sdim avgrhy,100,1000;全国平均リズム
	}
		time(2)=double(double(gettime(7))/1000+gettime(0)*365*30*3600*24+gettime(1)*30*3600*24+gettime(3)*3600*24+gettime(4)*3600+gettime(5)*60+gettime(6))
		for mo,0,m,1
			exist datafile(mo)
			alloc buf,strsize
			notesel buf
			if strsize!=-1:noteload datafile(mo)
			if mode==0:gosub *dataload;精密採点(プラス)
			if mode==1:gosub *dataload2;精密採点Ⅱ
			if mode==2:gosub *dataload3;精密採点DX
		next
		time(3)=double(double(gettime(7))/1000+gettime(0)*365*30*3600*24+gettime(1)*30*3600*24+gettime(3)*3600*24+gettime(4)*3600+gettime(5)*60+gettime(6))
		goto *sort
		stop
;===========================================================================
*dataload
;曲情報の処理(精密採点・プラス)
	sdim cont,1000000
	bload datafile(mo),cont ;入力htmlファイル 
	sdim output,1000000 
	notesel output 

	sdim requestno,7 
	dim i 
	dim len 
	dim mainpointer 
	dim pointer
	dim fileinfo,24
	sdim s,256 
	sdim ln,1024 

	;HTML解析スタート
	mainpointer = 0
	i = instr(cont,mainpointer,"<title>DAM★とも"):
	if i != -1:filetype = 0
	if i == -1:filetype = 1
		repeat 
				i = instr(cont,mainpointer,"実施日：") ;日付データの前に必ずある文字列を検索 
				if i = -1 : break ;無かったら抜ける 
				pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭 
				tim1(id)=strmid(cont,pointer,4);年
				tim2(id)=strmid(cont,pointer+5,2);月
				tim3(id)=strmid(cont,pointer+8,2);日
				tim4(id)=strmid(cont,pointer+11,2);時
				tim5(id)=strmid(cont,pointer+14,2);分
				tim6(id)=strmid(cont,pointer+17,2);秒

				i = instr(cont,mainpointer,"class=\"song");データの前に必ずある文字列を検索 
				if filetype== 0:pointer = mainpointer + i + 92 ;データの先頭 
				if filetype== 1:pointer = mainpointer + i + 88 ;データの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで 
				son(id) = strmid(cont,pointer,len) ;曲名データ取得

				i = instr(cont,mainpointer,"</a>(");得点データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 5 ;i の5文字先がデータの先頭 
				no1(id) = strmid(cont,pointer,4) ;リクエストNo.取得
				no2(id) = strmid(cont,pointer+5,2) ;

				i = instr(cont,mainpointer,"class=\"artist") 
				pointer = mainpointer + i + 15 ;i の15文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで 
				art(id) = strmid(cont,pointer,len) ;アーティストデータ取得

				i = instr(cont,mainpointer,"あなたの点数:");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 21 ;i の21文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで 
				poi(id) = double(strmid(cont,pointer,len));得点データ取得
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭
				if filetype == 1:pointer = mainpointer + i + 27 ;i の25文字先がデータの先頭 
				len = instr(cont,pointer,"秒") ;データは"秒"まで 				
				vib(id) = double(strmid(cont,pointer,len));ビブ長データ取得
	
				i = instr(cont,mainpointer,"あなたのビブラートのタイプは");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 124 ;i の124文字先がデータの先頭
				if filetype == 1:pointer = mainpointer + i + 101 ;i の101文字先がデータの先頭
				if filetype == 0:len = instr(cont,pointer,"\n") ;データは改行まで	
				if filetype == 1:len = instr(cont,pointer,"<") ;データは<まで
				vibt(id) = strmid(cont,pointer,len);ビブタイプデータ取得
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める

				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				if filetype == 1:pointer = mainpointer + i + 18 ;i の18文字先がデータの先頭 
				len = instr(cont,pointer,"回") ;データは"回"まで 
				sha(id) = strmid(cont,pointer,len);しゃくりデータ取得
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				if filetype == 1:pointer = mainpointer + i + 18 ;i の18文字先がデータの先頭 
				len = instr(cont,pointer,"%") ;データは"%"まで 
				mel(id) = strmid(cont,pointer,len);音程データ取得
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める

				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 57 ;i の57文字先がデータの先頭 
				if filetype == 1:pointer = mainpointer + i + 56 ;i の56文字先がデータの先頭 
				len = instr(cont,pointer,".gif") ;データは".gif"まで 
				rhy(id) = strmid(cont,pointer,len);リズムの上手さデータ取得
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める

				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				if filetype == 0:pointer = mainpointer + i + 61 ;i の61文字先がデータの先頭 
				if filetype == 1:pointer = mainpointer + i + 60 ;i の60文字先がデータの先頭 
				len = instr(cont,pointer,".gif") ;データは".gif"まで 
				yok(id) = strmid(cont,pointer,len);抑揚の上手さデータ取得
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで
				;こぶし
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで
				;高音域
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで
				;中音域
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで
				;低音域
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
				pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
				len = instr(cont,pointer,"<") ;データは"<"まで
				;?
				mainpointer = pointer ;class="field" が続くのでメインポインタを進める
	
				if id!=0:gosub *check
				if fl=0:id=id+1
				title ""+(i+1)+"ファイル目:"+"/"+notemax+":"+id+"曲検出"
		loop
	;XML解析スタート
	mainpointer = 0 
	repeat
			i = instr(cont,mainpointer,"<marking") ; 
			if i = -1 : break ;無かったら抜ける 

			i = instr(cont,mainpointer,"requestNo=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			no1(id) = strmid(cont,pointer,4) ;リクエストNo.取得
			no2(id) = strmid(cont,pointer+5,2);

			i = instr(cont,mainpointer,"contents=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			son(id) = strmid(cont,pointer,len) ;曲名データ取得

			i = instr(cont,mainpointer,"artist=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			art(id) = strmid(cont,pointer,len) ;アーティストデータ取得

			i = instr(cont,mainpointer,"date=") ;
			pointer = mainpointer + i + 6 ;i の6文字先がデータの先頭
			tim1(id)=strmid(cont,pointer,4);年
			tim2(id)=strmid(cont,pointer+5,2);月
			tim3(id)=strmid(cont,pointer+8,2);日
			tim4(id)=strmid(cont,pointer+11,2);時
			tim5(id)=strmid(cont,pointer+14,2);分
			tim6(id)=strmid(cont,pointer+17,2);秒

			i = instr(cont,mainpointer,"vibrato=") ;
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vib(id) = double(strmid(cont,pointer,len));ビブ長データ取得

			i = instr(cont,mainpointer,"vibratoType=") ;
			pointer = mainpointer + i + 13 ;i の13文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vibt(id) = strmid(cont,pointer,len);ビブタイプデータ取得
			if vibt(id)=="1":vibt(id)="A-1"
			if vibt(id)=="2":vibt(id)="A-2"
			if vibt(id)=="3":vibt(id)="A-3"
			if vibt(id)=="4":vibt(id)="B-1"
			if vibt(id)=="5":vibt(id)="B-2"
			if vibt(id)=="6":vibt(id)="B-3"
			if vibt(id)=="7":vibt(id)="C-1"
			if vibt(id)=="8":vibt(id)="C-2"
			if vibt(id)=="9":vibt(id)="C-3"

			i = instr(cont,mainpointer,"sob=") ;
			pointer = mainpointer + i + 5 ;i の5文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			sha(id) = strmid(cont,pointer,len);しゃくりデータ取得

			i = instr(cont,mainpointer,"pitch=") ;
			pointer = mainpointer + i + 7 ;i の5文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			mel(id) = strmid(cont,pointer,len);音程データ取得

			i = instr(cont,mainpointer,"rhythm=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			rhy(id) = strmid(cont,pointer,len);リズムの上手さデータ取得

			i = instr(cont,mainpointer,"modulation=") ;
			pointer = mainpointer + i + 12 ;i の12文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			yok(id) = strmid(cont,pointer,len);抑揚の上手さデータ取得

			i = instr(cont,mainpointer,"highPitch=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			melh(id) = strmid(cont,pointer,len);高音の上手さデータ取得

			i = instr(cont,mainpointer,"lowPitch=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			mell(id) = strmid(cont,pointer,len);低音の上手さデータ取得

			i = instr(cont,mainpointer,"measure=") ;
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			kob(id) = strmid(cont,pointer,len);こぶしデータ取得
			mainpointer = pointer ;メインポインタを進める

			i = instr(cont,mainpointer,">") ;
			pointer = mainpointer + i + 1 ;i の1文字先がデータの先頭
			poi(id) = double(strmid(cont,pointer,6));得点データ取得
			max_point(id) = poi(id)
			mainpointer = pointer ;メインポインタを進める

			if id!=0:gosub *check
			if fl=0:id=id+1
			title "XML:"+(mo+1)+"ファイル目:"+mainpointer+":"+id+"曲検出"+cnt
	loop
		
		return
	stop
;=dataload end===================================================================
*dataload2
;曲情報の処理(精密採点Ⅱ)
	sdim cont,1000000
	bload datafile(mo),cont ;入力htmlファイル 
	sdim output,1000000 
	notesel output 

	sdim requestno,7 
	dim i 
	dim len 
	dim mainpointer 
	dim pointer
	dim fileinfo,24
	sdim s,256 
	sdim ln,1024 

	;HTML解析スタート
	mainpointer = 0 
	i = instr(cont,mainpointer,"<title>DAM★とも"):
	if i != -1:filetype = 0 // <title>DAM★とも が存在
	if i == -1:filetype = 1 // <title>精密採点2 が存在
	repeat 
			i = instr(cont,mainpointer,"実施日：") ;日付データの前に必ずある文字列を検索 
			if i = -1 : break ;無かったら抜ける 
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭 
			tim1(id)=strmid(cont,pointer,4);年
			tim2(id)=strmid(cont,pointer+5,2);月
			tim3(id)=strmid(cont,pointer+8,2);日
			tim4(id)=strmid(cont,pointer+11,2);時
			tim5(id)=strmid(cont,pointer+14,2);分
			tim6(id)=strmid(cont,pointer+17,2);秒

			i = instr(cont,mainpointer,"class=\"song");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 92 ;データの先頭 
			if filetype == 1:pointer = mainpointer + i + 89 ;データの先頭 
			len = instr(cont,pointer,"<") ;データは"<"まで 
			son(id) = strmid(cont,pointer,len) ;曲名データ取得

			i = instr(cont,mainpointer,"</a>(");得点データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 5 ;i の5文字先がデータの先頭 
			no1(id) = strmid(cont,pointer,4) ;リクエストNo.取得
			no2(id) = strmid(cont,pointer+5,2) ;

			i = instr(cont,mainpointer,"class=\"artist") 
			pointer = mainpointer + i + 15 ;i の15文字先がデータの先頭 
			len = instr(cont,pointer,"<") ;データは"<"まで 
			art(id) = strmid(cont,pointer,len) ;アーティストデータ取得

			i = instr(cont,mainpointer,"あなたの点数:");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 21 ;i の21文字先がデータの先頭 
			len = instr(cont,pointer,"<") ;データは"<"まで 
			poi(id) = double(strmid(cont,pointer,len));得点データ取得

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
			len = instr(cont,pointer,"秒") ;データは"秒"まで 
			vib(id) = double(strmid(cont,pointer,len));ビブ長データ取得

			i = instr(cont,mainpointer,"あなたのビブラートのタイプは");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 123 ;i の123文字先がデータの先頭
			if filetype == 1:pointer = mainpointer + i + 101 ;i の101文字先がデータの先頭
			len = instr(cont,pointer,"<") ;データは<まで 
			vibt(id) = strmid(cont,pointer,len);ビブタイプデータ取得
;			if vib(id)==0.000:vibt(id)="無し"
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭 
			len = instr(cont,pointer,"回") ;データは"回"まで 
			sha(id) = strmid(cont,pointer,len);しゃくりデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める


			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭 
			len = instr(cont,pointer,"回") ;データは"回"まで 
			kob(id) = strmid(cont,pointer,len);こぶしデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める


			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭 
			len = instr(cont,pointer,"回") ;データは"回"まで 
			fal(id) = strmid(cont,pointer,len);フォールデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める


			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭 
			len = instr(cont,pointer,"%") ;データは"秒"まで 
			mel(id) = strmid(cont,pointer,len);音程データ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 68 ;i の68文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 76 ;i の72文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			mell(id) = strmid(cont,pointer,len);低音の上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			if filetype == 0:pointer = mainpointer + i + 68 ;i の68文字先がデータの先頭 
			if filetype == 1:pointer = mainpointer + i + 76 ;i の68文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			melh(id) = strmid(cont,pointer,len);高音の上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 70 ;i の70文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			vibi(id) = strmid(cont,pointer,len);ビブラートの上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 70 ;i の70文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			lont(id) = strmid(cont,pointer,len);ロングトーンの上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 70 ;i の70文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			yok(id) = strmid(cont,pointer,len);抑揚の上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			i = instr(cont,mainpointer,"class=\"field");データの前に必ずある文字列を検索 
			pointer = mainpointer + i + 66 ;i の66文字先がデータの先頭 
			len = instr(cont,pointer,".gif") ;データは".gif"まで 
			rhy(id) = strmid(cont,pointer,len);リズムの上手さデータ取得
			mainpointer = pointer ;class="field" が続くのでメインポインタを進める

			if id!=0:gosub *check
			if fl=0:id=id+1
			title ""+(mo+1)+"ファイル目:"+"/"+notemax+":"+id+"曲検出"

	loop

	;XML解析スタート
	mainpointer = 0 
	repeat
			i = instr(cont,mainpointer,"<marking") ; 
			if i = -1 : break ;無かったら抜ける 

			i = instr(cont,mainpointer,"requestNo=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			no1(id) = strmid(cont,pointer,4) ;リクエストNo.取得
			no2(id) = strmid(cont,pointer+5,2);

			i = instr(cont,mainpointer,"contents=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			son(id) = strmid(cont,pointer,len) ;曲名データ取得

			i = instr(cont,mainpointer,"artist=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			art(id) = strmid(cont,pointer,len) ;アーティストデータ取得

			i = instr(cont,mainpointer,"date=") ;
			pointer = mainpointer + i + 6 ;i の6文字先がデータの先頭
			tim1(id)=strmid(cont,pointer,4);年
			tim2(id)=strmid(cont,pointer+5,2);月
			tim3(id)=strmid(cont,pointer+8,2);日
			tim4(id)=strmid(cont,pointer+11,2);時
			tim5(id)=strmid(cont,pointer+14,2);分
			tim6(id)=strmid(cont,pointer+17,2);秒

			i = instr(cont,mainpointer,"vibrato=") ;
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vib(id) = double(strmid(cont,pointer,len));ビブ長データ取得

			i = instr(cont,mainpointer,"vibratoType=") ;
			pointer = mainpointer + i + 13 ;i の13文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vibt(id) = strmid(cont,pointer,len);ビブタイプデータ取得
			if vibt(id)=="1":vibt(id)="A-1"
			if vibt(id)=="2":vibt(id)="A-2"
			if vibt(id)=="3":vibt(id)="A-3"
			if vibt(id)=="4":vibt(id)="B-1"
			if vibt(id)=="5":vibt(id)="B-2"
			if vibt(id)=="6":vibt(id)="B-3"
			if vibt(id)=="7":vibt(id)="C-1"
			if vibt(id)=="8":vibt(id)="C-2"
			if vibt(id)=="9":vibt(id)="C-3"

			i = instr(cont,mainpointer,"vibratoRank=") ;
			pointer = mainpointer + i + 13 ;i の13文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vibi(id) = strmid(cont,pointer,len);ビブラートの上手さデータ取得

			i = instr(cont,mainpointer,"sob=") ;
			pointer = mainpointer + i + 5 ;i の5文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			sha(id) = strmid(cont,pointer,len);しゃくりデータ取得

			i = instr(cont,mainpointer,"pitch=") ;
			pointer = mainpointer + i + 7 ;i の5文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			mel(id) = strmid(cont,pointer,len);音程データ取得

			i = instr(cont,mainpointer,"rhythm=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			rhy(id) = strmid(cont,pointer,len);リズムの上手さデータ取得

			i = instr(cont,mainpointer,"modulation=") ;
			pointer = mainpointer + i + 12 ;i の12文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			yok(id) = strmid(cont,pointer,len);抑揚の上手さデータ取得

			i = instr(cont,mainpointer,"highPitch=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			melh(id) = strmid(cont,pointer,len);高音の上手さデータ取得

			i = instr(cont,mainpointer,"lowPitch=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			mell(id) = strmid(cont,pointer,len);低音の上手さデータ取得

			i = instr(cont,mainpointer,"measure=") ;
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			kob(id) = strmid(cont,pointer,len);こぶしデータ取得

			i = instr(cont,mainpointer,"fall=") ;
			pointer = mainpointer + i + 6 ;i の6文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			fal(id) = strmid(cont,pointer,len);フォールデータ取得

			i = instr(cont,mainpointer,"longTone=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			lont(id) = strmid(cont,pointer,len);ロングトーンデータ取得

			i = instr(cont,mainpointer,"rank=") ;
			pointer = mainpointer + i + 9 ;i の6文字前がデータの先頭
			poi(id) = double(strmid(cont,pointer,6));得点データ取得
			max_point(id) = poi(id)
			mainpointer = pointer ;メインポインタを進める


			if id!=0:gosub *check
			if fl=0:id=id+1
			title "XML:"+(mo+1)+"ファイル目:"+mainpointer+":"+id+"曲検出"+cnt
	loop

	return
	stop
;=====dataload2 end=======================================================
*dataload3

	;曲情報の処理(精密採点DX)
	sdim cont,1000000
	bload datafile(mo),cont ;入力htmlファイル 
	sdim output,1000000 
	notesel output 

	sdim requestno,7 
	dim i 
	dim len 
	dim mainpointer 
	dim pointer
	dim fileinfo,24
	sdim s,256 
	sdim ln,1024 

		;XML解析スタート
	mainpointer = 0 
	repeat
			i = instr(cont,mainpointer,"<marking") ; 
			if i = -1 : break ;無かったら抜ける 

			i = instr(cont,mainpointer,"requestNo=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			no1(id) = strmid(cont,pointer,4) ;リクエストNo.取得
			no2(id) = strmid(cont,pointer+5,2);

			i = instr(cont,mainpointer,"artist=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			art(id) = strmid(cont,pointer,len) ;アーティストデータ取得

			i = instr(cont,mainpointer,"contents=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			son(id) = strmid(cont,pointer,len) ;曲名データ取得

			i = instr(cont,mainpointer,"chartInterval=") ;
			pointer = mainpointer + i + 15 ;i の15文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			mel(id) = strmid(cont,pointer,len) ;チャート音程取得

			i = instr(cont,mainpointer,"chartStability=") ;
			pointer = mainpointer + i + 16 ;i の17文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			chstab(id) = strmid(cont,pointer,len) ;チャート安定性取得

			i = instr(cont,mainpointer,"chartExpressiveness=") ;
			pointer = mainpointer + i + 21 ;i の21文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			chexpress(id) = strmid(cont,pointer,len) ;チャート表現力取得

			i = instr(cont,mainpointer,"chartVibrateLongtone=") ;
			pointer = mainpointer + i + 22 ;i の22文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			chvib(id) = strmid(cont,pointer,len) ;チャートビブラート取得

			i = instr(cont,mainpointer,"chartRhythm=") ;
			pointer = mainpointer + i + 13 ;i の13文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			chrhy(id) = strmid(cont,pointer,len) ;チャートリズム取得

			i = instr(cont,mainpointer,"highPitch=") ;
			pointer = mainpointer + i + 11 ;i の11文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			melh(id) = strmid(cont,pointer,len);highPitchデータ取得

			i = instr(cont,mainpointer,"lowPitch=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			mell(id) = strmid(cont,pointer,len);lowPitchデータ取得

			i = instr(cont,mainpointer,"highTessitura=") ;
			pointer = mainpointer + i + 15 ;i の15文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			hightess(id) = strmid(cont,pointer,len);highTessituraデータ取得

			i = instr(cont,mainpointer,"lowTessitura=") ;
			pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			lowtess(id) = strmid(cont,pointer,len);lowTessituraデータ取得

			i = instr(cont,mainpointer,"modulation=") ;
			pointer = mainpointer + i + 12 ;i の12文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			yok(id) = strmid(cont,pointer,len);抑揚の上手さデータ取得

			i = instr(cont,mainpointer,"measure=") ;
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			kob(id) = strmid(cont,pointer,len);こぶしデータ取得

			i = instr(cont,mainpointer,"sob=") ;
			pointer = mainpointer + i + 5 ;i の5文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			sha(id) = strmid(cont,pointer,len);しゃくりデータ取得

			i = instr(cont,mainpointer,"fall=") ;
			pointer = mainpointer + i + 6 ;i の6文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			fal(id) = strmid(cont,pointer,len);フォールデータ取得

			i = instr(cont,mainpointer,"timing=") ;
			pointer = mainpointer + i + 8 ;i の8文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			rhy(id) = strmid(cont,pointer,len);リズムの上手さデータ取得(5が±0)

			i = instr(cont,mainpointer,"longTone=") ;
			pointer = mainpointer + i + 10 ;i の10文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			lont(id) = strmid(cont,pointer,len);ロングトーンデータ取得

			i = instr(cont,mainpointer,"vibrato=") ;精密採点IIとタグが同じだが内容が異なることに注意。
			pointer = mainpointer + i + 9 ;i の9文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vibi(id) = strmid(cont,pointer,len);ビブラートの上手さデータ取得

			i = instr(cont,mainpointer,"vibratoType=") ;
			pointer = mainpointer + i + 13 ;i の13文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vibt(id) = strmid(cont,pointer,len);ビブタイプデータ取得
			if vibt(id)=="0":vibt(id)="N";(ノンビブ形)
			if vibt(id)=="1":vibt(id)="A-1";(ボックス形)
			if vibt(id)=="2":vibt(id)="B-1";(ボックス形)
			if vibt(id)=="3":vibt(id)="C-1";(ボックス形)
			if vibt(id)=="4":vibt(id)="A-2";(ボックス形)
			if vibt(id)=="5":vibt(id)="B-2";(ボックス形)
			if vibt(id)=="6":vibt(id)="C-2";(ボックス形)
			if vibt(id)=="7":vibt(id)="A-3";(ボックス形)
			if vibt(id)=="8":vibt(id)="B-3";(ボックス形)
			if vibt(id)=="9":vibt(id)="C-3";(ボックス形)
			if vibt(id)=="10":vibt(id)="D";(上昇形)
			if vibt(id)=="11":vibt(id)="E";(下降形)
			if vibt(id)=="12":vibt(id)="F";(縮小形)
			if vibt(id)=="13":vibt(id)="G";(拡張形)
			if vibt(id)=="14":vibt(id)="H";(ひし形)
			if int(vibt(id))>14:vibt(id)="type15以降"


			i = instr(cont,mainpointer,"vibratoSumSeconds=") ;
			pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで
			vib(id) = double(strmid(cont,pointer,len));ビブ長データ取得

			i = instr(cont,mainpointer,"averageTotalPoint=") ;
			pointer = mainpointer + i + 19 ;i の19文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgtotal(id) = double(strmid(cont,pointer,len))/1000 ;全国平均点取得

			i = instr(cont,mainpointer,"averagePitch=") ;
			pointer = mainpointer + i + 14 ;i の14文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgpitch(id) = strmid(cont,pointer,len) ;全国平均音程取得

			i = instr(cont,mainpointer,"averageStability=") ;
			pointer = mainpointer + i + 18 ;i の18文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgstab(id) = strmid(cont,pointer,len) ;チャート安定性取得

			i = instr(cont,mainpointer,"averageExpressiveness=") ;
			pointer = mainpointer + i + 23 ;i の23文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgexpress(id) = strmid(cont,pointer,len) ;全国平均表現力取得

			i = instr(cont,mainpointer,"averageVibrateLongtone=") ;
			pointer = mainpointer + i + 24 ;i の24文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgvib(id) = strmid(cont,pointer,len) ;全国平均ビブラート取得

			i = instr(cont,mainpointer,"averageRhythm=") ;
			pointer = mainpointer + i + 15 ;i の15文字先がデータの先頭
			len = instr(cont,pointer,"\"") ;データは"まで 
			avgrhy(id) = strmid(cont,pointer,len) ;全国平均リズム取得

			i = instr(cont,mainpointer,"date=") ;
			pointer = mainpointer + i + 6 ;i の6文字先がデータの先頭
			tim1(id)=strmid(cont,pointer,4);年
			tim2(id)=strmid(cont,pointer+5,2);月
			tim3(id)=strmid(cont,pointer+8,2);日
			tim4(id)=strmid(cont,pointer+11,2);時
			tim5(id)=strmid(cont,pointer+14,2);分
			tim6(id)=strmid(cont,pointer+17,2);秒
			mainpointer = pointer ;メインポインタを進める

			i = instr(cont,mainpointer,">") ;
			pointer = mainpointer + i + 1 ;i の1文字先がデータの先頭
			len = instr(cont,pointer,"</marking") ;データは</markingまで
			poi(id) = double(strmid(cont,pointer,len));得点データ取得
			max_point(id) = poi(id)
			mainpointer = pointer ;メインポインタを進める


			if id!=0:gosub *check
			if fl=0:id=id+1
			title "XML:"+(mo+1)+"ファイル目:"+mainpointer+":"+id+"曲検出"+cnt
	loop


	return
	stop

;============================================================================
*check
	fl=0
	for cha,0,id,1
			if (tim1(cha)==tim1(id))&(tim2(cha)==tim2(id))&(tim3(cha)==tim3(id))&(tim4(cha)==tim4(id))&(tim5(cha)==tim5(id))&(tim6(cha)==tim6(id)) {
				fl=1:_break
			}
	next
	return
;===========================================================================================
*sort
;	for cha,0,id,1
;		n(cha)=cha
;	next
	
	for cha,0,id,1
		n(cha)=cha
		for chb,0,id,1
			if (no1(cha)==no1(chb))&(no2(cha)==no2(chb)) {;リクエストNo.が一致したとき
				if max_point(cha)<poi(chb):max_point(cha)=poi(chb)
			}
		next
	next

;==========================================================================
if sor==0 {
	;日付順(新→旧)にソート
	for chb,0,id,1
		dum1(chb)=int(tim1(chb))
		dum2(chb)=int(tim2(chb))
		dum3(chb)=int(tim3(chb))
		dum4(chb)=int(tim4(chb))
		dum5(chb)=int(tim5(chb))
	next
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if dum1(n(cha))>dum1(n(chb)) {
				gosub *sub_sort
			}
			if dum1(n(cha))==dum1(n(chb)) {
				if dum2(n(cha))>dum2(n(chb)) {
					gosub *sub_sort
				}
				if dum2(n(cha))==dum2(n(chb)) {
					if dum3(n(cha))>dum3(n(chb)) {
						gosub *sub_sort
					}
					if dum3(n(cha))==dum3(n(chb)) {
						if dum4(n(cha))>dum4(n(chb)) {
							gosub *sub_sort
						}
						if dum4(n(cha))==dum4(n(chb)) {
							if dum5(n(cha))>dum5(n(chb)) {
								gosub *sub_sort
							}
						}
					}
				}
			}
		next
	next
}
;==========================================================================
if sor==1 {
	;日付順(旧→新)にソート
	for chb,0,id,1
		dum1(chb)=int(tim1(chb))
		dum2(chb)=int(tim2(chb))
		dum3(chb)=int(tim3(chb))
		dum4(chb)=int(tim4(chb))
		dum5(chb)=int(tim5(chb))
	next
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if dum1(n(cha))<dum1(n(chb)) {
				gosub *sub_sort
			}
			if dum1(n(cha))==dum1(n(chb)) {
				if dum2(n(cha))<dum2(n(chb)) {
					gosub *sub_sort
				}
				if dum2(n(cha))==dum2(n(chb)) {
					if dum3(n(cha))<dum3(n(chb)) {
						gosub *sub_sort
					}
					if dum3(n(cha))==dum3(n(chb)) {
						if dum4(n(cha))<dum4(n(chb)) {
							gosub *sub_sort
						}
						if dum4(n(cha))==dum4(n(chb)) {
							if dum5(n(cha))<dum5(n(chb)) {
								gosub *sub_sort
							}
						}
					}
				}
			}
		next
	next
}
;==========================================================================
;得点順にソート
if sor==2 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if poi(n(cha))>poi(n(chb)) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;リクエストNo.順にソート
if sor==3 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(no1(n(cha)))<int(no1(n(chb))) {
				gosub *sub_sort
			}
			if int(no1(n(cha)))==int(no1(n(chb))) {
				if int(no2(n(cha)))<int(no2(n(chb))) {
					gosub *sub_sort
				}
			}
		next
	next
}
;==========================================================================
;曲名/アーティスト順にソート
	sdim dum6,500,id
if (sor==4)|(sor==5) {
	for chb,0,id,1
		if sor==4:dum6(chb)=son(chb)
		if sor==5:dum6(chb)=art(chb)
	next
	sortstr dum6,0
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		sortget n3,cha
		n(cha)=n3
	next
;同じ曲名を得点順にソート
	if sor==4 {
		for cha,0,id,1
			for chb,0,id,1
				if son(n(cha))==son(n(chb)) {
					if poi(n(cha))>poi(n(chb)) {
						gosub *sub_sort
					}
				}
			next
		next
	}
;同じアーティストをリクエストNo.順にソート
	if sor==5 {
		for cha,0,id,1
			for chb,0,id,1
				if art(n(cha))==art(n(chb)) {
					if int(no1(n(cha)))<int(no1(n(chb))) {
						gosub *sub_sort
					}
					if int(no1(n(cha)))==int(no1(n(chb))) {
						if int(no2(n(cha)))<int(no2(n(chb))) {
							gosub *sub_sort
						}
					}
				}
			next
		next
	}
}
;==========================================================================
;ビブ長順にソート
if sor==6 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if vib(n(cha))>vib(n(chb)) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;しゃくり回数順にソート
if sor==7 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(sha(n(cha)))>int(sha(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;音程順にソート
if sor==8 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(mel(n(cha)))>int(mel(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;リズム順にソート
if sor==9 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(rhy(n(cha)))<int(rhy(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;抑揚順にソート
if sor==10 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(yok(n(cha)))>int(yok(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;こぶし順にソート
if sor==11 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(kob(n(cha)))>int(kob(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;フォール順にソート
if sor==12 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(fal(n(cha)))>int(fal(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;低音順にソート
if sor==13 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(mell(n(cha)))>int(mell(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;高音順にソート
if sor==14 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(melh(n(cha)))>int(melh(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;ビブラートの上手さ順にソート
if sor==15 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(vibi(n(cha)))>int(vibi(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
;ロングトーンの上手さ順にソート
if sor==16 {
	for cha,0,id,1
		title "ソート中:"+(cha+1)+"/"+id+""
		for chb,0,id,1
			if int(lont(n(cha)))>int(lont(n(chb))) {
				gosub *sub_sort
			}
		next
	next
}
;==========================================================================
	if ki==0:goto *htmlsave
	if ki==1:goto *txtsave
	stop
;==============================================================================================
*sub_sort
		t=n(cha)
		n(cha)=n(chb)
		n(chb)=t
		return
		stop
;==========================================================
*htmlsave
	time(4)=double(double(gettime(7))/1000+gettime(0)*365*30*3600*24+gettime(1)*30*3600*24+gettime(3)*3600*24+gettime(4)*3600+gettime(5)*60+gettime(6))
	sdim rhyt,100,id
	alloc buff,100000
#if 0
	notesel buff
	noteadd "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\""
	noteadd "\"http://www.w3.org/TR/html4/loose.dtd\">"
	noteadd "<html>"
	noteadd "<head>"
	noteadd "<meta http-equiv=\"Content-Type\""
	noteadd "content=\"text/html; charset=x-sjis\">"
	noteadd "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"
	noteadd "<link href=\"seimitu.css\" rel=\"stylesheet\" type=\"text/css\">"
	if mode==0:noteadd 	"<title>精密採点(プラス)結果</title>\n</head>"
	if mode==1:noteadd 	"<title>精密採点Ⅱ結果</title>\n</head>"
	if mode==2:noteadd 	"<title>精密採点DX結果</title>\n</head>"
	noteadd "<body>"
	noteadd "<hr>"
	if gettime(5)<10 {
		noteadd "<br><br>更新時刻:"+gettime(0)+"/"+gettime(1)+"/"+gettime(3)+"　"+gettime(4)+":"+0+gettime(5)+""
		}
		else {
		noteadd "<br><br>更新時刻:"+gettime(0)+"/"+gettime(1)+"/"+gettime(3)+"　"+gettime(4)+":"+gettime(5)+""
	}
	noteadd "<table width=\"1000\">"
	noteadd "<tr>"
	if mode!=2 {
		if sor==2:noteadd "<th class=\"left\">得点▼</th>"
		if sor!=2:noteadd "<th class=\"left\">得点</th>"
	}
	if mode==2 {
		if sor==2:noteadd "<th class=\"left\">得点▼<br><br>(全国平均点)</th>"
		if sor!=2:noteadd "<th class=\"left\">得点<br><br>(全国平均点)</th>"
	}
	noteadd "<th>過去最高点</th>"
	if sor==4:noteadd "<th colspan=\"2\">曲名▲/アーティスト</th>"
	if sor==5:noteadd "<th colspan=\"2\">曲名/アーティスト▲</th>"
	if (sor!=4)&(sor!=5):noteadd "<th colspan=\"2\">曲名/アーティスト</th>"
	if sor==6:noteadd "<th>ビブラート▼</th>"
	if sor!=6:noteadd "<th>ビブラート</th>"
	if sor==7:noteadd "<th>しゃくり▼</th>"
	if sor!=7:noteadd "<th>しゃくり</th>"
	if sor==11:noteadd "<th>こぶし▼</th>"
	if sor!=11:noteadd "<th>こぶし</th>"
	if sor==12:noteadd "<th>フォール▼</th>"
	if sor!=12:noteadd "<th>フォール</th>"
	if sor==8:noteadd "<th>音程▼</th>"
	if sor!=8:noteadd "<th>音程</th>"
	if sor==13:noteadd "<th>低音▼</th>"
	if sor!=13:noteadd "<th>低音</th>"
	if sor==14:noteadd "<th>高音▼</th>"
	if sor!=14:noteadd "<th>高音</th>"
	if sor==15:noteadd "<Th><FONT size=1>ビブラ<br>ートの<br>上手さ▼</FONT></Th>"
	if sor!=15:noteadd "<Th><FONT size=1>ビブラ<br>ートの<br>上手さ</FONT></Th>"
	if sor==16:noteadd "<Th><FONT size=1>ロング<br>トーン<br>の上手さ▼</FONT></Th>"
	if sor!=16:noteadd "<Th><FONT size=1>ロング<br>トーン<br>の上手さ</FONT></Th>"
	if sor==10:noteadd "<th>抑揚▼</th>"
	if sor!=10:noteadd "<th>抑揚</th>"
	if sor==9:noteadd "<th>リズム▲</th>"
	if sor!=9:noteadd "<th>リズム</th>"
	if mode==2 {
		noteadd "<th>音程</th>"
		noteadd "<th>安定性</th>"
		noteadd "<th>表現力</th>"
		noteadd "<th>ビブラート</th>"
		noteadd "<th>リズム</th>"
		noteadd "<th>チャート</td>"

	}
	if sor==0:noteadd "<th class=\"right\">精密採点実施日▼</th>"
	if sor==1:noteadd "<th class=\"right\">精密採点実施日▲</th>"
	if (sor!=1)&(sor!=0):noteadd "<th class=\"right\">精密採点実施日</th>"
	noteadd	"</tr>"
	sdim st,100,100
	for i,0,id,1
		title "HTML出力中:"+(i+1)+"/"+id
		noteadd	"<tr>"
		st(0)="MS5"
		if poi(n(i))>=95:st(0)="MS0"
		if (poi(n(i))>=90)&(poi(n(i))<95):st(0)="MS1"
		if (poi(n(i))>=85)&(poi(n(i))<90):st(0)="MS2"
		if (poi(n(i))>=80)&(poi(n(i))<85):st(0)="MS3"
		if (poi(n(i))>=75)&(poi(n(i))<80):st(0)="MS4"
		if (mode==0|mode==1) :noteadd "<td rowspan=\"2\" class="+st(0)+">"+strf("%2.3f",poi(n(i)))+"<span class=\"ten\">点</span></td>"
		if mode==2:noteadd "<td  class="+st(0)+">"+strf("%2.3f",poi(n(i)))+"<span class=\"ten\">点</span></td>"
		noteadd "<td rowspan=\"2\" class=\"id\">"+strf("%2.3f",max_point(n(i)))+"</td>"
		noteadd "<td class=\"no\">No."+(i+1)+"</td>"
		noteadd "<td class=\"song\">"+son(n(i))+"</td>"
		noteadd "<td>"+vibt(n(i))+"</td>"
		;しゃくり
		if mode==2:noteadd	"<td class=\"sha\">"+sha(n(i))+"回</td>"
		if mode!=2:noteadd	"<td rowspan=\"2\" class=\"sha\">"+sha(n(i))+"回</td>"
		;こぶし・フォール
		if mode==0 {
			noteadd	"<td rowspan=\"2\" class=\"sha\">"+kob(n(i))+"</td>"
			noteadd	"<td rowspan=\"2\" class=\"sha\">"+fal(n(i))+"</td>"
		}
		if mode==1 {
			noteadd	"<td rowspan=\"2\" class=\"sha\">"+kob(n(i))+"回</td>"
			noteadd	"<td rowspan=\"2\" class=\"sha\">"+fal(n(i))+"回</td>"
		} 
		if mode==2 {
			noteadd	"<td class=\"sha\">"+kob(n(i))+"回</td>"
			noteadd	"<td class=\"sha\">"+fal(n(i))+"回</td>"
		} 
		;音程
		if mode!=2:noteadd "<td rowspan=\"2\" class=\"sha\">"+mel(n(i))+"%</td>"
		if mode==2:noteadd "<td class=\"sha\">"+mel(n(i))+"%</td>"
		;高音・低音
		if mode==0 {
			noteadd "<td rowspan=\"2\" class=\"sha\"></td>"
			noteadd "<td rowspan=\"2\" class=\"sha\"></td>"
		}
		if mode==1 {
			if int(mell(n(i)))==1:noteadd "<td rowspan=\"2\" class=\"sha\">×</td>"
			if int(mell(n(i)))==2:noteadd "<td rowspan=\"2\" class=\"sha\">△</td>"
			if int(mell(n(i)))==3:noteadd "<td rowspan=\"2\" class=\"sha\">○</td>"
			if int(mell(n(i)))==4:noteadd "<td rowspan=\"2\" class=\"sha\">◎</td>"
			if int(melh(n(i)))==1:noteadd "<td rowspan=\"2\" class=\"sha\">×</td>"
			if int(melh(n(i)))==2:noteadd "<td rowspan=\"2\" class=\"sha\">△</td>"
			if int(melh(n(i)))==3:noteadd "<td rowspan=\"2\" class=\"sha\">○</td>"
			if int(melh(n(i)))==4:noteadd "<td rowspan=\"2\" class=\"sha\">◎</td>"
		}
		if mode==2 {
			noteadd "<td colspan=\"2\"class=\"sha\">"+ mell(n(i)) + "-" + melh(n(i)) + "<br>(" + lowtess(n(i)) + "-" +hightess(n(i))+ ")</td>"
		}
		;ビブラートの上手さ
		st(1)="R5"
		if (mode==1|mode==2) {
			if int(vibi(n(i)))==10:st(1)="R1"
			if int(vibi(n(i)))==9:st(1)="R2"
			if int(vibi(n(i)))==8:st(1)="R3"
			if (int(vibi(n(i)))<=7)&(int(vibi(n(i)))>=5):st(1)="R4"
		}
		if mode!=2:noteadd "<td rowspan=\"2\" class="+st(1)+">"+vibi(n(i))+"</td>"
		if mode==2:noteadd "<td class="+st(1)+">"+vibi(n(i))+"</td>"		

		;ロングトーンの上手さ
		st(1)="R5"
		if (mode==1|mode==2) {
			if int(lont(n(i)))==10:st(1)="R1"
			if int(lont(n(i)))==9:st(1)="R2"
			if int(lont(n(i)))==8:st(1)="R3"
			if (int(lont(n(i)))<=7)&(int(lont(n(i)))>=5):st(1)="R4"
		}
		if mode!=2:noteadd "<td rowspan=\"2\" class="+st(1)+">"+lont(n(i))+"</td>"
		if mode==2:noteadd "<td class="+st(1)+">"+lont(n(i))+"</td>"

		;抑揚
		st(1)="R5"
		if int(yok(n(i)))==10:st(1)="R1"
		if int(yok(n(i)))==9:st(1)="R2"
		if int(yok(n(i)))==8:st(1)="R3"
		if (int(yok(n(i)))<=7)&(int(yok(n(i)))>=5):st(1)="R4"
		if mode!=2:noteadd "<td rowspan=\"2\" class="+st(1)+">"+yok(n(i))+"</td>"
		if mode==2:noteadd "<td class="+st(1)+">"+yok(n(i))+"</td>"

		;リズム
		if (mode==0|mode==1) {
			if int(rhy(n(i)))==-4:rhyt(n(i))="+4"
			if int(rhy(n(i)))==-3:rhyt(n(i))="+3"
			if int(rhy(n(i)))==-2:rhyt(n(i))="+2"
			if int(rhy(n(i)))==-1:rhyt(n(i))="+1"
			if int(rhy(n(i)))==0: rhyt(n(i))="±0"
			if int(rhy(n(i)))==1:rhyt(n(i))="-1"
			if int(rhy(n(i)))==2:rhyt(n(i))="-2"
			if int(rhy(n(i)))==3:rhyt(n(i))="-3"
			if int(rhy(n(i)))==4:rhyt(n(i))="-4"
			noteadd "<td rowspan=\"2\" class=\"sha\">"+rhyt(n(i))+"</td>"
		}
		;チャート
		if mode==2 {
			noteadd "<td class=\"sha\">"+rhy(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+mel(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+chstab(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+chexpress(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+chvib(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+chrhy(n(i))+"</td>"
		}
		if mode==2 {
			string="https:\/\/chart.googleapis.com\/chart?cht=r&chxt=y,x&chls=4|4&chco=FF0000,00FF00&chxp=0,0,20,40,60,80,100&chd=t:"+avgpitch(n(i))
			string = string + ","+ avgstab(n(i)) +"," + avgexpress(n(i)) + "," + avgvib(n(i)) + "," + avgrhy(n(i)) + "," + avgpitch(n(i))
			string = string + "|" + mel(n(i)) + "," + chstab(n(i)) + "," + chexpress(n(i)) + "," + chvib(n(i)) + "," + chrhy(n(i)) + "," + mel(n(i))
			string = string + "&chxl=1:|%e9%9f%b3%e7%a8%8b|%e5%ae%89%e5%ae%9a%e6%80%a7|%e8%a1%a8%e7%8f%be%e5%8a%9b|%e3%83%93%e3%83%96%e3%83%a9%e3%83%bc%e3%83%88|%e3%83%aa%e3%82%ba%e3%83%a0"
			string = string + "&chm=s,FF0000,0,-1,12,0|s,FFFFFF,0,-1,8,0|o,00FF00,1,-1,12,0|o,FFFFFF,1,-1,8,0&chts=000000,13
				encode_init
				pStr = ""+art(n(i))+"／"+son(n(i))+"  ("+no1(n(i))+"-"+no2(n(i))+")"
			
				sdim encbuf
				repeat encode(pStr, CODEPAGE_S_JIS, dStr, CODEPAGE_UTF_8)
					tmp = peek(dStr, cnt)
					if range(tmp, 0x29, 0x3a) | range(tmp, 0x40, 0x5b) | range(tmp, 0x60, 0x7b) {
						encbuf += strf("%c", tmp)
					} else {
						encbuf += strf("%%%02x", tmp)
					}
				loop
			;	mes encbuf

			string = string + "&chtt=" + encbuf
			string = string + "&chdl=%e5%85%a8%e5%9b%bd%e5%b9%b3%e5%9d%87|%e8%87%aa%e5%88%86&chs=350x260"
			noteadd "<td rowspan=\"2\" class=\"sha\"><a href="+ string +" target=_blank>見る<\/a><\/td>"

		}
		noteadd "<td rowspan=\"2\" class=\"sha\">"+tim1(n(i))+"/"+tim2(n(i))+"/"+tim3(n(i))+" "+tim4(n(i))+":"+tim5(n(i))+":"+tim6(n(i))+"</td>"
		noteadd "</tr>"
		noteadd	"<tr>"
		;全国平均点
		if mode==2:noteadd "<td class=\"id\">("+strf("%2.3f",avgtotal(n(i)))+"点)</td>"
		noteadd "<td class=\"id\">"+no1(n(i))+"-"+no2(n(i))+"</td>"
		noteadd "<td class=\"singer\">"+art(n(i))+"</td>"
		noteadd	"<td class=\"vib\">"+strf("%2.1f",vib(n(i)))+"秒</td>"
		if mode==2 {
			;声域(鍵盤表示)
			noteadd "<td colspan=10 class=sha>"
			noteadd "<TABLE style=\"border:2px solid #000000; border-collapse:collapse;\">"
			noteadd "<tr>"
			key=41:gosub *hakken13
			key=42:gosub *kokken
			key=43:gosub *hakken12
			key=44:gosub *kokken
			key=45:gosub *hakken12
			key=46:gosub *kokken
			key=47:gosub *hakken13
	
			for cha,0,3,1
				key=cha*12+48:gosub *hakken13
				key=cha*12+49:gosub *kokken		
				key=cha*12+50:gosub *hakken12				
				key=cha*12+51:gosub *kokken
				key=cha*12+52:gosub *hakken13
				key=cha*12+53:gosub *hakken13
				key=cha*12+54:gosub *kokken
				key=cha*12+55:gosub *hakken12
				key=cha*12+56:gosub *kokken
				key=cha*12+57:gosub *hakken12
				key=cha*12+58:gosub *kokken
				key=cha*12+59:gosub *hakken13
				noteadd "\n"
			next
			noteadd "</tr>\n<tr>"
			key=41:gosub *hakken24
			key=43:gosub *hakken24
			key=45:gosub *hakken24
			key=47:gosub *hakken24

			for cha,0,3,1
				key=cha*12+48:gosub *hakken25
				key=cha*12+50:gosub *hakken24
				key=cha*12+52:gosub *hakken24
				key=cha*12+53:gosub *hakken24
				key=cha*12+55:gosub *hakken24
				key=cha*12+57:gosub *hakken24
				key=cha*12+59:gosub *hakken24
				noteadd "\n"

			next
			noteadd "</tr>"
			noteadd "</table>"
			noteadd "</td>"
		
			;チャートパラメータ
			noteadd "<td class=\"sha\">"+avgpitch(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+avgstab(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+avgexpress(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+avgvib(n(i))+"</td>"
			noteadd "<td class=\"sha\">"+avgrhy(n(i))+"</td>"
		}
		noteadd "</tr>"
	next
	noteadd "</table><br>"
	noteadd "集計 by "+seimituhan
	noteadd "<br><hr>"
	noteadd"</body></html>"
 	notesave filename(1)
#else
;v0.643以降note系命令廃止
	set_string ""
	add_string "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n"
	add_string "\"http://www.w3.org/TR/html4/loose.dtd\">\n"
	add_string "<html>\n"
	add_string "<head>\n"
	add_string "<meta http-equiv=\"Content-Type\"\n"
	add_string "content=\"text/html; charset=x-sjis\">\n"
	add_string "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">\n"
	add_string "<link href=\"seimitu.css\" rel=\"stylesheet\" type=\"text/css\">\n"
	if mode==2:add_string "<script src=\"seimitsu.js\" type=\"text/javascript\"></script>\n"
	if mode==0:add_string 	"<title>精密採点(プラス)結果</title>\n</head>\n"
	if mode==1:add_string 	"<title>精密採点Ⅱ結果</title>\n</head>\n"
	if mode==2:add_string 	"<title>精密採点DX結果</title>\n</head>\n"
	add_string "<body>\n"
	add_string "<hr>\n"
	if gettime(5)<10 {
		add_string "<br><br>更新時刻:"+gettime(0)+"/"+gettime(1)+"/"+gettime(3)+"　"+gettime(4)+":"+0+gettime(5)+"\n"
		}
		else {
		add_string "<br><br>更新時刻:"+gettime(0)+"/"+gettime(1)+"/"+gettime(3)+"　"+gettime(4)+":"+gettime(5)+"\n"
	}
		add_string "<table width=\"1000\">"
	add_string "<tr>"
	if mode!=2 {
		if sor==2:add_string "<th class=\"left\">得点▼</th>"
		if sor!=2:add_string "<th class=\"left\">得点</th>"
	}
	if mode==2 {
		if sor==2:add_string "<th class=\"left\">得点▼<br><br>(全国平均点)</th>"
		if sor!=2:add_string "<th class=\"left\">得点<br><br>(全国平均点)</th>"
	}
	add_string "<th>過去最高点</th>"
	if sor==4:add_string "<th colspan=\"2\">曲名▲/アーティスト</th>"
	if sor==5:add_string "<th colspan=\"2\">曲名/アーティスト▲</th>"
	if (sor!=4)&(sor!=5):add_string "<th colspan=\"2\">曲名/アーティスト</th>"
	if sor==6:add_string "<th>ビブラート▼</th>"
	if sor!=6:add_string "<th>ビブラート</th>"
	if sor==7:add_string "<th>しゃくり▼</th>"
	if sor!=7:add_string "<th>しゃくり</th>"
	if sor==11:add_string "<th>こぶし▼</th>"
	if sor!=11:add_string "<th>こぶし</th>"
	if sor==12:add_string "<th>フォール▼</th>"
	if sor!=12:add_string "<th>フォール</th>"
	if sor==8:add_string "<th>音程▼</th>"
	if sor!=8:add_string "<th>音程</th>"
	if sor==13:add_string "<th>低音▼</th>"
	if sor!=13:add_string "<th>低音</th>"
	if sor==14:add_string "<th>高音▼</th>"
	if sor!=14:add_string "<th>高音</th>"
	if sor==15:add_string "<Th><FONT size=1>ビブラ<br>ートの<br>上手さ▼</FONT></Th>"
	if sor!=15:add_string "<Th><FONT size=1>ビブラ<br>ートの<br>上手さ</FONT></Th>"
	if sor==16:add_string "<Th><FONT size=1>ロング<br>トーン<br>の上手さ▼</FONT></Th>"
	if sor!=16:add_string "<Th><FONT size=1>ロング<br>トーン<br>の上手さ</FONT></Th>"
	if sor==10:add_string "<th>抑揚▼</th>"
	if sor!=10:add_string "<th>抑揚</th>"
	if sor==9:add_string "<th>リズム▲</th>"
	if sor!=9:add_string "<th>リズム</th>"
	if mode==2 {
		add_string "<th>音程</th>"
		add_string "<th>安定性</th>"
		add_string "<th>表現力</th>"
		add_string "<th>ビブラート</th>"
		add_string "<th>リズム</th>"
		add_string "<th>チャート</td>"

	}
	if sor==0:add_string "<th class=\"right\">精密採点実施日▼</th>"
	if sor==1:add_string "<th class=\"right\">精密採点実施日▲</th>"
	if (sor!=1)&(sor!=0):add_string "<th class=\"right\">精密採点実施日</th>"
	add_string	"</tr>\n"
	sdim st,100,100
	for i,0,id,1
		title "HTML出力中:"+(i+1)+"/"+id
		add_string	"<tr>\n"
		st(0)="MS5"
		if poi(n(i))>=95:st(0)="MS0"
		if (poi(n(i))>=90)&(poi(n(i))<95):st(0)="MS1"
		if (poi(n(i))>=85)&(poi(n(i))<90):st(0)="MS2"
		if (poi(n(i))>=80)&(poi(n(i))<85):st(0)="MS3"
		if (poi(n(i))>=75)&(poi(n(i))<80):st(0)="MS4"
		if (mode==0|mode==1) :add_string "<td rowspan=\"2\" class="+st(0)+">"+strf("%2.3f",poi(n(i)))+"<span class=\"ten\">点</span></td>"
		if mode==2:add_string "<td  class="+st(0)+">"+strf("%2.3f",poi(n(i)))+"<span class=\"ten\">点</span></td>"
		add_string "<td rowspan=\"2\" class=\"id\">"+strf("%2.3f",max_point(n(i)))+"</td>"
		add_string "<td class=\"no\">No."+(i+1)+"</td>"
		add_string "<td class=\"song\">"+son(n(i))+"</td>"
		add_string "<td>"+vibt(n(i))+"</td>"
		;しゃくり
		if mode==2:add_string	"<td class=\"sha\">"+sha(n(i))+"回</td>"
		if mode!=2:add_string	"<td rowspan=\"2\" class=\"sha\">"+sha(n(i))+"回</td>"
		;こぶし・フォール
		if mode==0 {
			add_string	"<td rowspan=\"2\" class=\"sha\">"+kob(n(i))+"</td>"
			add_string	"<td rowspan=\"2\" class=\"sha\">"+fal(n(i))+"</td>"
		}
		if mode==1 {
			add_string	"<td rowspan=\"2\" class=\"sha\">"+kob(n(i))+"回</td>"
			add_string	"<td rowspan=\"2\" class=\"sha\">"+fal(n(i))+"回</td>"
		} 
		if mode==2 {
			add_string	"<td class=\"sha\">"+kob(n(i))+"回</td>"
			add_string	"<td class=\"sha\">"+fal(n(i))+"回</td>"
		} 
		;音程
		if mode!=2:add_string "<td rowspan=\"2\" class=\"sha\">"+mel(n(i))+"%</td>"
		if mode==2:add_string "<td class=\"sha\">"+mel(n(i))+"%</td>"
		;高音・低音
		if mode==0 {
			add_string "<td rowspan=\"2\" class=\"sha\"></td>"
			add_string "<td rowspan=\"2\" class=\"sha\"></td>"
		}
		if mode==1 {
			if int(mell(n(i)))==1:add_string "<td rowspan=\"2\" class=\"sha\">×</td>"
			if int(mell(n(i)))==2:add_string "<td rowspan=\"2\" class=\"sha\">△</td>"
			if int(mell(n(i)))==3:add_string "<td rowspan=\"2\" class=\"sha\">○</td>"
			if int(mell(n(i)))==4:add_string "<td rowspan=\"2\" class=\"sha\">◎</td>"
			if int(melh(n(i)))==1:add_string "<td rowspan=\"2\" class=\"sha\">×</td>"
			if int(melh(n(i)))==2:add_string "<td rowspan=\"2\" class=\"sha\">△</td>"
			if int(melh(n(i)))==3:add_string "<td rowspan=\"2\" class=\"sha\">○</td>"
			if int(melh(n(i)))==4:add_string "<td rowspan=\"2\" class=\"sha\">◎</td>"
		}
		if mode==2 {
			add_string "<td colspan=\"2\"class=\"sha\">"+ mell(n(i)) + "-" + melh(n(i)) + "<br>(" + lowtess(n(i)) + "-" +hightess(n(i))+ ")</td>"
		}
		;ビブラートの上手さ
		st(1)="R5"
		if (mode==1|mode==2) {
			if int(vibi(n(i)))==10:st(1)="R1"
			if int(vibi(n(i)))==9:st(1)="R2"
			if int(vibi(n(i)))==8:st(1)="R3"
			if (int(vibi(n(i)))<=7)&(int(vibi(n(i)))>=5):st(1)="R4"
		}
		if mode!=2:add_string "<td rowspan=\"2\" class="+st(1)+">"+vibi(n(i))+"</td>"
		if mode==2:add_string "<td class="+st(1)+">"+vibi(n(i))+"</td>"		

		;ロングトーンの上手さ
		st(1)="R5"
		if (mode==1|mode==2) {
			if int(lont(n(i)))==10:st(1)="R1"
			if int(lont(n(i)))==9:st(1)="R2"
			if int(lont(n(i)))==8:st(1)="R3"
			if (int(lont(n(i)))<=7)&(int(lont(n(i)))>=5):st(1)="R4"
		}
		if mode!=2:add_string "<td rowspan=\"2\" class="+st(1)+">"+lont(n(i))+"</td>"
		if mode==2:add_string "<td class="+st(1)+">"+lont(n(i))+"</td>"

		;抑揚
		st(1)="R5"
		if int(yok(n(i)))==10:st(1)="R1"
		if int(yok(n(i)))==9:st(1)="R2"
		if int(yok(n(i)))==8:st(1)="R3"
		if (int(yok(n(i)))<=7)&(int(yok(n(i)))>=5):st(1)="R4"
		if mode!=2:add_string "<td rowspan=\"2\" class="+st(1)+">"+yok(n(i))+"</td>"
		if mode==2:add_string "<td class="+st(1)+">"+yok(n(i))+"</td>"

		;リズム
		if (mode==0|mode==1) {
			if int(rhy(n(i)))==-4:rhyt(n(i))="+4"
			if int(rhy(n(i)))==-3:rhyt(n(i))="+3"
			if int(rhy(n(i)))==-2:rhyt(n(i))="+2"
			if int(rhy(n(i)))==-1:rhyt(n(i))="+1"
			if int(rhy(n(i)))==0: rhyt(n(i))="±0"
			if int(rhy(n(i)))==1:rhyt(n(i))="-1"
			if int(rhy(n(i)))==2:rhyt(n(i))="-2"
			if int(rhy(n(i)))==3:rhyt(n(i))="-3"
			if int(rhy(n(i)))==4:rhyt(n(i))="-4"
			add_string "<td rowspan=\"2\" class=\"sha\">"+rhyt(n(i))+"</td>"
		}
		;チャート
		if mode==2 {
			add_string "<td class=\"sha\">"+rhy(n(i))+"</td>"
			add_string "<td class=\"sha\">"+mel(n(i))+"</td>"
			add_string "<td class=\"sha\">"+chstab(n(i))+"</td>"
			add_string "<td class=\"sha\">"+chexpress(n(i))+"</td>"
			add_string "<td class=\"sha\">"+chvib(n(i))+"</td>"
			add_string "<td class=\"sha\">"+chrhy(n(i))+"</td>"
		}
		if mode==2 {
			string="https:\/\/chart.googleapis.com\/chart?cht=r&chxt=y,x&chls=4|4&chco=FF0000,00FF00&chxp=0,0,20,40,60,80,100&chd=t:"+avgpitch(n(i))
			string = string + ","+ avgstab(n(i)) +"," + avgexpress(n(i)) + "," + avgvib(n(i)) + "," + avgrhy(n(i)) + "," + avgpitch(n(i))
			string = string + "|" + mel(n(i)) + "," + chstab(n(i)) + "," + chexpress(n(i)) + "," + chvib(n(i)) + "," + chrhy(n(i)) + "," + mel(n(i))
			string = string + "&chxl=1:|%e9%9f%b3%e7%a8%8b|%e5%ae%89%e5%ae%9a%e6%80%a7|%e8%a1%a8%e7%8f%be%e5%8a%9b|%e3%83%93%e3%83%96%e3%83%a9%e3%83%bc%e3%83%88|%e3%83%aa%e3%82%ba%e3%83%a0"
			string = string + "&chm=s,FF0000,0,-1,12,0|s,FFFFFF,0,-1,8,0|o,00FF00,1,-1,12,0|o,FFFFFF,1,-1,8,0&chts=000000,13
				encode_init
				pStr = ""+art(n(i))+"／"+son(n(i))+"  ("+no1(n(i))+"-"+no2(n(i))+")"
			
				sdim encbuf
				repeat encode(pStr, CODEPAGE_S_JIS, dStr, CODEPAGE_UTF_8)
					tmp = peek(dStr, cnt)
					if range(tmp, 0x29, 0x3a) | range(tmp, 0x40, 0x5b) | range(tmp, 0x60, 0x7b) {
						encbuf += strf("%c", tmp)
					} else {
						encbuf += strf("%%%02x", tmp)
					}
				loop
			;	mes encbuf

			string = string + "&chtt=" + encbuf
			string = string + "&chdl=%e5%85%a8%e5%9b%bd%e5%b9%b3%e5%9d%87|%e8%87%aa%e5%88%86&chs=350x260"
			add_string "<td rowspan=\"2\" class=\"sha\"><a href="+ string +" target=_blank>見る<\/a><\/td>"

		}
		add_string "<td rowspan=\"2\" class=\"sha\">"+tim1(n(i))+"/"+tim2(n(i))+"/"+tim3(n(i))+" "+tim4(n(i))+":"+tim5(n(i))+":"+tim6(n(i))+"</td>"
		add_string "</tr>"
		add_string	"<tr>"
		;全国平均点
		if mode==2:add_string "<td class=\"id\">("+strf("%2.3f",avgtotal(n(i)))+"点)</td>"
		add_string "<td class=\"id\">"+no1(n(i))+"-"+no2(n(i))+"</td>"
		add_string "<td class=\"singer\">"+art(n(i))+"</td>"
		add_string	"<td class=\"vib\">"+strf("%2.1f",vib(n(i)))+"秒</td>"
		
			;声域(鍵盤表示)
			add_string "<td colspan=10 class=sha>"
		#if 0
			add_string "<TABLE style=\"border:2px solid #000000; border-collapse:collapse;\">"
			add_string "<tr>"
			key=41:gosub *hakken13
			key=42:gosub *kokken
			key=43:gosub *hakken12
			key=44:gosub *kokken
			key=45:gosub *hakken12
			key=46:gosub *kokken
			key=47:gosub *hakken13
	
			for cha,0,3,1
				key=cha*12+48:gosub *hakken13
				key=cha*12+49:gosub *kokken		
				key=cha*12+50:gosub *hakken12				
				key=cha*12+51:gosub *kokken
				key=cha*12+52:gosub *hakken13
				key=cha*12+53:gosub *hakken13
				key=cha*12+54:gosub *kokken
				key=cha*12+55:gosub *hakken12
				key=cha*12+56:gosub *kokken
				key=cha*12+57:gosub *hakken12
				key=cha*12+58:gosub *kokken
				key=cha*12+59:gosub *hakken13
			next
			add_string "</tr><tr>"
			key=41:gosub *hakken24
			key=43:gosub *hakken24
			key=45:gosub *hakken24
			key=47:gosub *hakken24

			for cha,0,3,1
				key=cha*12+48:gosub *hakken25
				key=cha*12+50:gosub *hakken24
				key=cha*12+52:gosub *hakken24
				key=cha*12+53:gosub *hakken24
				key=cha*12+55:gosub *hakken24
				key=cha*12+57:gosub *hakken24
				key=cha*12+59:gosub *hakken24
			next
			add_string "</tr>"
			add_string "</table>"
		#else
			add_string "<script type=\"text/javascript\">"
			add_string "		drawTess("+lowtess(n(i))+","+highTess(n(i))+","+mell(n(i))+","+melh(n(i))+");"
			add_string "</script>"
		#endif
			add_string "</td>"
		
			;チャートパラメータ
			add_string "<td class=\"sha\">"+avgpitch(n(i))+"</td>"
			add_string "<td class=\"sha\">"+avgstab(n(i))+"</td>"
			add_string "<td class=\"sha\">"+avgexpress(n(i))+"</td>"
			add_string "<td class=\"sha\">"+avgvib(n(i))+"</td>"
			add_string "<td class=\"sha\">"+avgrhy(n(i))+"</td>"
		
		add_string "</tr>\n"
	next
	add_string "</table><br>"
	add_string "集計 by "+seimituhan
	add_string "<br><hr>"
	add_string"</body></html>"
	get_string buff
 	bsave filename(1),buff,-1
#endif

	time(1)=double(double(gettime(7))/1000+gettime(0)*365*30*3600*24+gettime(1)*30*3600*24+gettime(3)*3600*24+gettime(4)*3600+gettime(5)*60+gettime(6))
 	dialog "ファイルを"+filename(1)+"に保存しました。\n経過時間"+strf("%2.3f",(time(1)-time(0)))+"秒\n集計"+strf("%2.3f",(time(3)-time(2)))+"秒\nHTML出力"+strf("%2.3f",(time(1)-time(4)))+"秒",0,"終了" 
	stop
;==============================================================
*txtsave
	stop
;======================
;灰 key<mell(n(i))またはkey>melh(n(i))
;無 key>=lowtess(n(i))かつkey<=hightess(n(i))
;赤 key>mell(n(i))かつkey<lowtess(n(i))、または、key<=melh(n(i))かつkey>hightess(n(i))

#if 0
#else
*kokken
	if (key<int( mell( n(i) ) )|key>int( melh( n(i) ) )) {
		add_string "<TD colspan=2 bgcolor=#717075>&nbsp;</TD>";<!-- 黒 "+key+"-->";灰
	}
	if (key>=int(lowtess(n(i))) & key<=int(hightess(n(i)))) {
		add_string "<TD colspan=2 bgcolor=#000000>&nbsp;</TD>";<!-- 黒 "+key+"-->";無
	} 
	if (key>=int( mell( n(i) ) )&key<int(lowtess(n(i)))) {
		add_string "<TD colspan=2 bgcolor=#742226>&nbsp;</TD>";<!-- 黒 "+key+"-->";赤
	}
	if (key<=int( melh( n(i) ) ) &key>int(hightess(n(i)))) {
		add_string "<TD colspan=2 bgcolor=#742226>&nbsp;</TD>";<!-- 黒 "+key+"-->";赤
	}
	return
	stop
*hakken12
	if (key<int( mell( n(i) ) )|key>int( melh( n(i) ) )) {
		add_string "<TD colspan=2 class=\"hakken1g\">&nbsp;</TD>";<!-- "+key+" -->";灰
	}
	if (key>=int(lowtess(n(i))) & key<=int(hightess(n(i)))) {
		add_string "<TD colspan=2 class=\"hakken1\">&nbsp;</TD>";<!-- "+key+" -->";無
	}
	if (key>=int( mell( n(i) ) )&key<int(lowtess(n(i)))) {
		add_string "<TD colspan=2 class=\"hakken1r\">&nbsp;</TD>";<!-- "+key+" -->";赤	
	}
	if (key<=int( melh( n(i) ) ) &key>int(hightess(n(i)))) {
		add_string "<TD colspan=2 class=\"hakken1r\">&nbsp;</TD>";<!-- "+key+" -->";赤	
	}
	return
	stop

*hakken13
	if (key<int( mell( n(i) ) )|key>int( melh( n(i) ) )) {
		add_string "<TD colspan=3 class=\"hakken1g\">&nbsp;</TD>";<!-- "+key+" -->";灰	
	}
	if (key>=int(lowtess(n(i))) & key<=int(hightess(n(i)))) {
		add_string "<TD colspan=3 class=\"hakken1\">&nbsp;</TD>";<!-- "+key+" -->";無
	}
	if (key>=int( mell( n(i) ) )&key<int(lowtess(n(i)))) {
		add_string "<TD colspan=3 class=\"hakken1r\">&nbsp;</TD>";<!-- "+key+" -->";赤
	}
	if (key<=int( melh( n(i) ) ) &key>int(hightess(n(i)))) {
		add_string "<TD colspan=3 class=\"hakken1r\">&nbsp;</TD>";<!-- "+key+" -->";赤
	}
	return
	stop
*hakken24
	if (key<int( mell( n(i) ) )|key>int( melh( n(i) ) )) {
		add_string "<TD colspan=4 class=\"hakken2g\">&nbsp;</TD>";<!-- "+key+" -->";灰
	}
	if (key>=int(lowtess(n(i))) & key<=int(hightess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2\">&nbsp;</TD>";<!-- "+key+" -->";無
	}
	if (key>=int( mell( n(i) ) )&key<int(lowtess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2r\">&nbsp;</TD>";<!-- "+key+" -->";赤
	}
	if (key<=int( melh( n(i) ) ) &key>int(hightess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2r\">&nbsp;</TD>";<!-- "+key+" -->";赤
	}	
	return
	stop
*hakken25
	;Cの印がついた鍵盤
	if (key<int( mell( n(i) ) )|key>int( melh( n(i) ) )) {
		add_string "<TD colspan=4 class=\"hakken2g\">・</TD>";<!-- "+key+" -->";灰
	}
	if (key>=int(lowtess(n(i))) & key<=int(hightess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2\">・</TD>";<!-- "+key+" -->";無
	}
	if (key>=int( mell( n(i) ) )&key<int(lowtess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2r\">・</TD>";<!-- "+key+" -->";赤
	}
	if (key<=int( melh( n(i) ) ) &key>int(hightess(n(i)))) {
		add_string "<TD colspan=4 class=\"hakken2r\">・</TD>";<!-- "+key+" -->";赤
	}	
	return
#endif
	stop
