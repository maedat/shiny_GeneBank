
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny) #shinyを使うためにlibrary shinyをインポートします
library(DT) #表形式の出力をよしなにやるためにDTライブラリも入れます

shinyUI(  #shinyUI関数内にuiの内容を書いていきます。
  navbarPage( #トップ項目を宣言します（ここをさらに割ることで、さらに複雑な構造のページを作れます。詳しくは後述
    
    titlePanel("LJ3.0"), #ぺージタイトルを入れます（画面に表示されるタイトルです）
    
    sidebarLayout(  #sidebarを使うことを宣言します。ユーザー入力用です
      sidebarPanel( #sidebarPanaelを使うことを宣言し、表示する内容を書きます
        "sidebar panel",  #sidebarのIDを入力します
        helpText("入力された遺伝子のアノテーション情報を表示する。"), #画面に表示される案内用テキストです。
        textInput("id",  #textInbutボックスを使うことを宣言し、idという名前を入れます。server.r側で、入力された内容を参照するためにこの名前が使われます。
                  label = "Choose a variable to display",  #画面に表示される案内用テキストです。
                  value = "Ljchlorog3v0000080.1") #初期値があるときは、このように入れます。
      ),
      mainPanel(    #mainPanelを使うことを宣言します。結果出力用です
        tabsetPanel(type = "tabs", #タブ形式で複数の項目を切り替えできるようにします。表示内容などは結構柔軟に変えられるのでよしなに。
                    tabPanel("Summary", #タブその１の設定です 名前をSummaryとします。この名前はタブの部分に表示されます。
                             DT::dataTableOutput("table1")),  #テーブルの表示の仕方を設定します。DT::dataTableOutputで、出力内容がDTの形式であることを示しています。名前をtable1とします。これがserver.r側で出力先を参照するときに使われます。
                    tabPanel("refseq", #上と同様にタブその２を設定します。
                             DT::dataTableOutput("table2")),
                    tabPanel("GeneOntrogy", 
                             DT::dataTableOutput("table3")),
                    tabPanel("Domain", #タブその4(名前Domain)にはinterproscanのhtml出力をそのまま表示するようにします。
                             htmlOutput("Pfam")),  #htmlOutputを使うことで出力内容がhtmlであることを知らせています
                    tabPanel("FPKM",   #タブその5(名前FPKM)にはFPKM値をggplotを使って図にした内容を表示することにします。
                             plotOutput("FPKMplot"),  #plotOutputを使うことで出力内容がplotであることを知らせています
                             downloadButton(outputId = "down", label = "Download as pdf"))  #図をダウンロードしたいとき用にボタンを作っておきます。
        )
      )
    )
  ))