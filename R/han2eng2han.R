# library(compiler)
# using cmpfun() did not improve the performance much

# f1 <- createFunc_case_switch()
# f2 <- cmpfun(f1)
#microbenchmark(times = 10, unit = "ms", # milliseconds
#               f1("Yes, That's the way to go"),
#               f2("Yes, That's the way to go"))

#lns = readLines('test.txt')
#microbenchmark(times = 10, unit = "ms", # milliseconds
#               f1(lns),
#               f2(lns))
#Unit: milliseconds
#expr    min     lq    mean  median    uq    max neval
#f1(lns) 0.0981 0.0984 0.15393 0.09905 0.101 0.6317    10
#f2(lns) 0.0983 0.0985 0.09961 0.09865 0.100 0.1059    10

library(data.table)

createFunc_case_switch = function() {
  id <- paste0(
    paste0("'",letters,"' <> '", LETTERS, "';\n"),
    paste0("'",LETTERS,"' <> '", letters, "';\n"), collapse='')
  func = function(x) {
    stringi::stri_trans_general(x, id=id, rules=TRUE)
  }
}

createHAutomata2 = function() {
  ch_han = 'ㅂㅈㄷㄱㅅㅛㅕㅑㅐㅔㅁㄴㅇㄹㅎㅗㅓㅏㅣㅋㅌㅊㅍㅠㅜㅡ'  # 한타
  ch_han_shifted = 'ㅃㅉㄸㄲㅆㅛㅕㅑㅒㅖㅁㄴㅇㄹㅎㅗㅓㅏㅣㅋㅌㅊㅍㅠㅜㅡ' # 한타를 SHIFT를 누르고 쳤을 때
  ch_eng = 'qwertyuiopasdfghjklzxcvbnm' # 영타
  ch_eng_shifted = 'QWERTYUIOPASDFGHJKLZXCVBNM' # 영타 + SHIFT
  ch_jamo = c(
    "\u1107", #ㅂ
    "\u110c", #ㅈ
    "\u1103", #ㄷ
    "\u1100", #ㄱ
    "\u1109", #ㅅ
    "\u116d", #ㅛ
    "\u1167", #ㅕ
    "\u1163", #ㅑ
    "\u1162", #ㅐ
    "\u1166", #ㅔ
    "\u1106", #ㅁ
    "\u1102", #ㄴ
    "\u110b", #ㅇ
    "\u1105", #ㄹ
    "\u1112", #ㅎ
    "\u1169", #ㅗ
    "\u1165", #ㅓ
    "\u1161", #ㅏ
    "\u1175", #ㅣ
    "\u110f", #ㅋ
    "\u1110", #ㅌ
    "\u110e", #ㅊ
    "\u1111", #ㅍ
    "\u1172", #ㅠ
    "\u116e", #ㅜ
    "\u1173") #ㅡ
  ch_jamo_shifted = c(
    "\u1108", #ㅃ
    "\u110d", #ㅉ
    "\u1104", #ㄸ
    "\u1101", #ㄲ
    "\u110a", #ㅆ
    '\u116d', #ㅛ
    "\u1167", #ㅕ
    "\u1163", #ㅑ
    "\u1164", #ㅒ
    "\u1168", #ㅖ
    "\u1106", #ㅁ
    "\u1102", #ㄴ
    "\u110b", #ㅇ
    "\u1105", #ㄹ
    "\u1112", #ㅎ
    "\u1169", #ㅗ
    "\u1165", #ㅓ
    "\u1161", #ㅏ
    "\u1175", #ㅣ
    "\u110f", #ㅋ
    "\u1110", #ㅌ
    "\u110e", #ㅊ
    "\u1111", #ㅍ
    "\u1172", #ㅠ
    "\u116e", #ㅜ
    "\u1173") #ㅡ

  ch_jamos = c(ch_jamo, ch_jamo_shifted)
  ch_hans = c(unlist(strsplit(ch_han, "")),
              unlist(strsplit(ch_han_shifted, "")))
  to_keep = !duplicated(ch_jamos)
  ch_jamos = ch_jamos[to_keep]
  ch_hans = ch_hans[to_keep]

  id_jamo <- paste0(
    paste0("'",ch_jamos ,"' <> '", unlist(strsplit(ch_hans, "")), "';\n"),
    collapse='')
  # cat(id_jamo)

  dt_eng_han =
    data.table::data.table(key_eng = unlist(strsplit(paste0(ch_eng,
                                                ch_eng_shifted), "")),
               key_han = unlist(strsplit(paste0(ch_han,
                                                ch_han_shifted), ""))
    )

  data.table::setkey(dt_eng_han, key_eng)
  #input_eng = "github.com/kmounlp/nEnER"
  HAutomata2 = function(input_eng) {
    input_eng_dt = data.table::data.table(key_eng = unlist(strsplit(input_eng, "")))

    #output_han = dt_eng_han[input_eng_dt, on='key_eng']
    output_han = merge(input_eng_dt, dt_eng_han, by='key_eng', all.x=TRUE, sort=FALSE)
    #output_han = merge(dt_eng_han, input_eng_dt, by='key_eng', all.x=TRUE)
    # 그리고 마지막으로 해당사항이 없다면 그대로 보존한다.
    #output_han[is.na(key_han), key_han:=key_eng]
    wh = which(is.na(output_han$key_han))
    data.table::set(output_han,
                    i=wh,
                    j='key_han',
                    value=output_han$key_eng[wh])
    han = paste0(output_han$key_han, collapse='')
    #stringi::stri_trans_nfc(han)
    #KoNLP::HangulAutomata(han, isForceConv = TRUE, isKeystroke = FALSE)
    #KoNLP::HangulAutomata(han, isForceConv = FALSE, isKeystroke = FALSE)
    KoNLP::HangulAutomata(stringi::stri_trans_nfkc(han),
                          isForceConv = TRUE, isKeystroke = FALSE)

    cat('* han :', han, '\n')

    tryCatch(KoNLP::HangulAutomata(han,
                              isForceConv = TRUE, isKeystroke = FALSE),
             error= function(e) {
               cat('!E: first HangulAutomata()\n')
               han2 <- KoNLP::HangulAutomata(stringi::stri_trans_nfkc(han),
                                             isForceConv = TRUE, isKeystroke = FALSE)
               stringi::stri_trans_general(han2, id=id_jamo, rules=TRUE)
             })
    #
  }

  HAutomata2
}

HAutomata2 = createHAutomata2()
#HAutomata2("github.com/kmounlp/nEnER")

createFunc_eng_to_han = function() {
  func = function(x) {
    #KoNLP::HangulAutomata(x,
    #                        isForceConv=TRUE,
    #                         isKeystroke=TRUE)
    HAutomata2(x)
  }
}
### ???
# HangulAutomata('durltk', isForceConv = TRUE, isKeystroke = TRUE)
## [1] "여기사"
#
# HangulAutomata('githubcomkmounlpnEnER', isForceConv = TRUE, isKeystroke = TRUE)
## Error in .jcall(KoHangulAuto, "S", "convert", input) :
##   java.lang.NullPointerException
#
# HangulAutomata('햐소ㅕㅠ채ㅡㅏㅜㅐㅕㅟㅔㅜ뚜ㄸㄲ', isForceConv = TRUE, isKeystroke = TRUE)
## [1] "햐소ㅕㅠ채ㅡㅏㅜㅐㅕㅟㅔㅜ뚜ㄸㄲ"

createFunc_han_to_eng = function() {
  func = function(x) {
    paste0(
      KoNLP::convertHangulStringToKeyStrokes(x, isFullwidth=FALSE),
      collapse = '')
  }
}

createFunc_to_strokes = function() {
  id <- paste0(
    paste0("'",LETTERS[1:4],"' > '", letters[1:4], "';\n", collapse = ''),
    paste0("'",LETTERS[6:14],"' > '", letters[6:14], "';\n", collapse = ''),
    paste0("'",LETTERS[19:26][c(-2,-5)],"' > '", letters[19:26][c(-2,-5)], "';\n", collapse = ''),
    collapse='')
  func = function(x) {
    stringi::stri_trans_general(x, id=id, rules=TRUE)
  }
}

eng_to_han = createFunc_eng_to_han()
han_to_eng = createFunc_han_to_eng()
to_strokes = createFunc_to_strokes()
case_switch = createFunc_case_switch()

change_keystrokes <- function() {
  # Get the active document
  ctx <- rstudioapi::getActiveDocumentContext()

  if (!is.null(ctx)) {
    selected_text <- ctx$selection[[1]]$text
    cat("* selected :", selected_text, "\n")
    n_han = stringi::stri_count_regex(selected_text, "\\p{Hangul}")
    n_eng = stringi::stri_count_regex(selected_text, "[A-Za-z]")
    cat("  - n_han:", n_han, "\n")
    cat("  - n_eng:", n_eng, "\n")
    if (n_han > n_eng) {
      selected_text = han_to_eng(selected_text)
    } else {
      selected_text2 = eng_to_han(selected_text)
      n_eng = stringi::stri_count_regex(selected_text2, "[A-Za-z]")
      if (n_eng > 0) {
        selected_text =eng_to_han(to_strokes(selected_text))
      } else {
        selected_text = selected_text2
      }

    }

    rstudioapi::modifyRange(ctx$selection[[1]]$range, selected_text)
    #print(str(x))
    #print(x)
    #rstudioapi::setSelectionRanges(x$ranges)
  }
}

change_case = function() {

  ctx <- rstudioapi::getActiveDocumentContext()

  if (!is.null(ctx)) {
    selected_text <- ctx$selection[[1]]$text
    #cat("* selected :", selected_text, "\n")
    selected_text <- case_switch(selected_text)
    rstudioapi::modifyRange(ctx$selection[[1]]$range, selected_text)
  }
}


## Unicode
## Hangul Jungseong I
## Hangul Letter I
##




