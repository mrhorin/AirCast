# window.air.Introspector.Console.log()
viewerObj = null

# viewer初期化
viewerIniInitialize = ->
	viewerObj = new window.Viewer()
	viewerObj.setNavListener()
	viewerObj.setTaskBarListener()
	viewerObj.windowSettings()
	viewerObj.loadViewerSection()
	window.air.Introspector.Console.log()

class window.Viewer
	# buttonStatus ボタンの状態を持つ連想配列
	# html HTMLLoaderインスタンスviewer_section.html

	constructor: ->
		@buttonStatus =
			"play": false
			"pause": false
			"air": false
			"get-thread": false
			"get-bbs": false
			"add-bbs": false
			"jimaku": false
		# 掲示板データベースに接続
		@bbsDb = new BbsDb()
		@bbsDb.connect()
		@bbsDb.create()
		@bbsDbView = new BbsDbView()
		@bbsDbController = new BbsDbController(@bbsDb, @bbsDbView)

	# ボタンの状態を切り替える
	switchButton: =>
		$.each @buttonStatus, (key, index) =>
			button = window.document.getElementById(key)
			if @buttonStatus[key][index]
				$(button).addClass("on")
			else
				$(button).removeClass("on")


	# window設定読み込み
	windowSettings: =>
		so = window.air.SharedObject.getLocal("superfoo")
		# ウィンドウサイズ位置の復帰
		if so.data.appX? && so.data.appY?
			window.nativeWindow.x = so.data.appX
			window.nativeWindow.y = so.data.appY
			window.nativeWindow.width = so.data.appWidth
			window.nativeWindow.height = so.data.appHeight
		# ウィンドウを表示
		window.nativeWindow.visible = true
		# URLを復帰
		if so.data.bbsUrl
			$(@url).val(so.data.bbsUrl)
		else
			$(@url).val("http://jbbs.shitaraba.net/computer/10298/")
		# タスクバーの移動イベント
		taskBar = window.document.getElementById("task-bar")
		taskBar.addEventListener("mousedown", @omMoveWindow)
		# viewerのリサイズイベント
		viewer = window.document.getElementById("arrows")
		viewer.addEventListener("mousedown", @onResizeWindow)
		# ウィンドウを閉じた時
		window.nativeWindow.stage.addEventListener(window.air.Event.CLOSING, @closeHandler)

	loadViewerSection: =>
		# viewer_section.htmlの読み込み
		url = new window.air.URLRequest("../haml/viewer_section.html")
		@html = new window.air.HTMLLoader()
		@html.scaleX = 1
		@html.scaleY = 1
		@html.load(url)

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = window.nativeWindow.width - 20
		@html.height = window.nativeWindow.height - 80
		@html.x = 10
		@html.y = 65

		# viewerウィンドウがリサイズされた時のイベント
		window.nativeWindow.addEventListener(window.air.Event.RESIZE, @htmlResize)
		window.nativeWindow.stage.addChild(@html)
		window.nativeWindow.stage.scaleMode = "noScale"
		window.nativeWindow.stage.align = "topLeft"

	loadViewerSection2: =>
		initOptions = new window.air.NativeWindowInitOptions()
		bounds = new window.air.Rectangle(10, 10, 600, 400)
		@html = window.air.HTMLLoader.createRootWindow(false, initOptions, true, bounds)
		urlReq = new window.air.URLRequest("../haml/viewer_section.html")
		@html.load(urlReq)

		# HTMLLoaderのサイズをNativeWindowに合わせる
		@html.width = window.nativeWindow.width - 20
		@html.height = window.nativeWindow.height - 80
		@html.x = 10
		@html.y = 65

		@html.stage.nativeWindow.close()

		# viewerウィンドウがリサイズされた時のイベント
		window.nativeWindow.addEventListener(window.air.Event.RESIZE, @htmlResize)
		window.nativeWindow.stage.addChild(@html)
		window.nativeWindow.stage.scaleMode = "noScale"
		window.nativeWindow.stage.align = "topLeft"

	# viewerウィンドウムーブハンドラ
	omMoveWindow: (event) ->
		window.nativeWindow.startMove()

	# viewerウィンドウリサイズハンドラ
	onResizeWindow: (event) =>
		window.nativeWindow.startResize("BR")

	# viewerウィンドウリサイズイベントハンドラ
	htmlResize: (event) =>
		# HTMLLoaderのサイズをviewerウィンドウに合わせる
		@html.width = window.nativeWindow.width - 20
		@html.height = window.nativeWindow.height - 80

	# タスクバーにイベントリスナーをセット
	setTaskBarListener: ->
		# 閉じる
		close = window.document.getElementById("close")
		close.addEventListener "click", @closeHandler
		# 最小化
		minimize = window.document.getElementById("minimize")
		minimize.addEventListener "click", @minimizeHandler
		# 最大化
		# maximize = window.document.getElementById("maximize")
		# maximize.addEventListener "click", maximizeHandler

	closeHandler: (event) =>
		# ウィンドウサイズ位置を保存
		# viewerウィンドウ
		so = window.air.SharedObject.getLocal("superfoo")
		so.data.appX = window.nativeWindow.x
		so.data.appY = window.nativeWindow.y
		so.data.appWidth = window.nativeWindow.width
		so.data.appHeight = window.nativeWindow.height
		# 字幕
		if @buttonStatus["jimaku"]
			@threadController.jimakuView.saveSettings()
		# アプリケーションを終了
		window.air.NativeApplication.nativeApplication.exit()

	minimizeHandler: (event) ->
		window.nativeWindow.minimize()

	# maximizeHandler = (event) ->
	# 	window.nativeWindow.maximize()

	# ナビバーにイベントリスナーをセット
	setNavListener: ->
		@play = window.document.getElementById("play")
		@play.addEventListener "click", @playHandler
		@pause = window.document.getElementById("pause")
		@pause.addEventListener "click", @pauseHandler
		@air = window.document.getElementById("air")
		@air.addEventListener "click", @airHandler
		@getThread = window.document.getElementById("get-thread")
		@getThread.addEventListener "click", @getThreadHandler
		@getBbs = window.document.getElementById("get-bbs")
		@getBbs.addEventListener "click", @getBbsHandler
		@addBbs = window.document.getElementById("add-bbs")
		@addBbs.addEventListener "click", @addBbsHandler
		@url = window.document.getElementById("url")

	playHandler: =>
		if @threadController? && !@threadController.resLoadFlag
			# 自動更新ON
			@threadController.resLoadFlag = true
			@threadController.resLoadOn()
			$(@play).addClass("on")
			$(@pause).removeClass("on")

	pauseHandler: =>
		# 自動更新がONか？
		if @threadController? && @threadController.resLoadFlag
			# 自動更新OFF
			@threadController.resLoadFlag = false
			@threadController.resLoadOff()
			$(@play).removeClass("on")
			$(@pause).addClass("on")

	airHandler: =>
		if @buttonStatus["jimaku"]
			@threadController.switchClassAir()
			if @threadController.airFlag
				$("#air").addClass("on")
				@buttonStatus["air"] = true
			else
				$("#air").removeClass("on")
				@buttonStatus["air"] = false

	# スレッド選択時のハンドラ
	# BbsView.printSubjectからの呼び出し
	clickThreadHandler: =>
		# スレッドの処理系インスタンスの生成
		@thread = new Thread(@bbsView.clickedThread, @bbs.url)
		# スレッドの表示系インスタンスを生成
		@threadView = new ThreadView()
		# sectionタグを空に
		@threadView.sectionToEmpty()
		# レスを取得
		res = @thread.getRes()
		# レスを表示
		@threadView.printRes(res)

		# 字幕の表示系インスタンスを生成
		@jimakuView = new ThreadJimakuView("../haml/jimaku.html")
		# 字幕を生成
		@jimakuView.create()
		@jimakuView.activated()
		# 字幕表示フラグをON
		@buttonStatus["jimaku"] = true

		# ThreadControllerを生成
		@threadController = new ThreadController(@thread, @threadView, @jimakuView)

	# スレッド一覧取得ハンドラ
	getThreadHandler: =>
		# 字幕が表示中か？
		if @buttonStatus["jimaku"]
			# 字幕を閉じる
			@threadController.jimakuView.closed()
			# 字幕の時計を止める
			@threadController.jimakuClockOff()
			@buttonStatus["jimaku"] = false
			$(@air).removeClass("on")

		# 自動更新OFF
		@pauseHandler()
		# 掲示板の処理系インスタンスを生成
		@bbs = new Bbs($("#url").val())
		# 掲示板の表示系インスタンスを生成
		@bbsView = new BbsView(@bbs, @bbsDb)
		# スレッド一覧を描画
		@bbsView.printSubject()
		# URLを保存
		so = window.air.SharedObject.getLocal("superfoo")
		so.data.bbsUrl = $("#url").val()

	getBbsHandler: =>
		# if @buttonStatus["get-bbs"]
		# 	@buttonStatus =
		# 		"play": false
		# 		"pause": false
		# 		"air": false
		# 		"get-thread": false
		# 		"get-bbs": true
		# 		"add-bbs": true
		# 	@switchButton()
		@bbsDbController.getBbsList()

	addBbsHandler: =>
		@bbsDbController.getAddBbs()