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

createFunc_case_switch = function() {
  id <- paste0(
    paste0("'",letters,"' <> '", LETTERS, "';\n"),
    paste0("'",LETTERS,"' <> '", letters, "';\n"), collapse='')
  func = function(x) {
    stringi::stri_trans_general(x, id=id, rules=TRUE)
  }
}

createFunc_eng_to_han = function() {
  func = function(x) {
    KoNLP::HangulAutomata(x,
                          isForceConv=TRUE,
                          isKeystroke=TRUE)
  }
}

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
