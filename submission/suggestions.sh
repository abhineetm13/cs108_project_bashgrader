#!/usr/bin/env python3
# Closest match to a word in a list is printed
# Input: Word, list of words(multiline string with each line having a word)
# Output: Closest match
import sys
import difflib

word=sys.argv[1]
list=sys.argv[2]


words_list = list.strip().split("\n")

# difflib.get_close_matches(word,list,n=1) gives the closest match to the word in the list
close_match = difflib.get_close_matches(word,words_list,n=1)

if len(close_match) == 1:
    print("Did you mean \""+close_match[0]+"\"?")