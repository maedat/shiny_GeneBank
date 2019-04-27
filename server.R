
library(shiny)
library(DT)
library(tidyverse)
library(stringr)
library(ggbeeswarm)


df1_sum <- read_tsv("./summary.txt") 
df2_swissprot <- read_tsv("./swissprot_out_fmt6.txt") 

df1_sum_mod <-
  df1_sum %>%
  mutate(Uniprot_Lj_link=str_c("<a href='https://www.uniprot.org/uniprot/", 
                               Uniprot_Lj_hit,
                               "'",
                               "target = '_blank'",
                               ">",
                               Uniprot_Lj_hit,
                               "</a>")  
  )%>%
  select(id,Uniprot_Lj_link, Uniprot_Lj_descri, Uniprot_Lj_gene, Blast2go_descri)　

## タブその２に表示する予定のswissprot blast　hit項目の整形
df2_swissprot_mod<-
  df2_swissprot %>%
  mutate(swiss_link=str_c("<a href='https://www.uniprot.org/uniprot/", 
                          sseqid,
                          "'",
                          "target = '_blank'",
                          ">",
                          sseqid,
                          "</a>")  #uniprotにリンクで飛べるようにしておきます。
  )%>%
  select(qseqid, swiss_link, pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore)　#出力する項目順に整形しておきます。

FPKM_data <- read_tsv("./fpkm.txt")  %>%
  tidyr::gather(key = sample, value = FPKM, -id)%>%
  mutate(condition = str_replace(sample, "_1|_2|_3|_4", ""))





shinyServer( #入力がなされたときの処理の内容を書きます
  function(input, output)
  {  
    output$table1<-
    DT::renderDataTable( 
      {df1_sum_mod %>% filter(id == input$id)}, 
      rownames = FALSE,
      extensions = c('Buttons'),
      escape = FALSE,
      options = list(dom = 'Blfrtip',
                     buttons = c('csv', 'excel', 'pdf')
      )
    )
    
    
    output$table2 <- #table1のときと同じです。ただ今回は複数行がヒットする点がちがいます。
      DT::renderDataTable({df2_swissprot_mod %>% filter(qseqid == input$id)},
                          filter='top',
                          rownames = FALSE,
                          escape = FALSE,
                          extensions = c('Buttons'),
                          options = list(dom = 'Blfrtip',
                                         buttons = c('csv', 'excel', 'pdf')
                          )
      )
  
        output$Pfam <-renderUI ({  #HTMLのデータはrenderUIで処理してPfamに渡します
                            my_file<-str_c("html/",
                                           input$id,
                                           ".html") #HTMLへのパスをinput$idと合わせて指定します
                            
                            
                            tags$iframe(  #tagsを使うことで、ファイルの内容を特定のHTMLタグに挟んで渡すことができます。今回はiframeで挟んでわたします。出力するファイルはsrc=で指定します。
                              seamless="seamless",
                              width="900", #iframeのサイズを指定します。このくらいでいい感じと思います。
                              height="1200",
                              src=my_file)
                            })

        output$FPKMplot <-renderPlot({        
        ggplot(FPKM_data %>%
                 filter(id == input$id), 
               aes(x = condition, y = FPKM,  fill=condition))+
          stat_summary(fun.y = "mean", geom = "bar")+
          geom_quasirandom(width=0.1,cex = 1)+
          theme_bw()+
          theme(
            axis.text.x = element_text(angle = 45, hjust = 1),
            axis.text=element_text(size=12)
          )
        })
        
        output$down <- downloadHandler(
          filename =  "output.pdf",
          content = function(file) {
            ggsave(file, 
                   ggplot(FPKM_data %>%
                            filter(id == input$id), 
                          aes(x = condition, y = FPKM,  fill=condition))+
                     stat_summary(fun.y = "mean", geom = "bar")+
                     geom_quasirandom(width=0.1,cex = 1)+
                     theme_bw()+
                     theme(
                       axis.text.x = element_text(angle = 45, hjust = 1),
                       axis.text=element_text(size=12)
                     ))
          })
  })
