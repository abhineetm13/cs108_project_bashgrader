#!/usr/bin/env python3
# Code to check for file, main.csv in submission.sh itself

import sys
import numpy as np
import matplotlib.pyplot as plt

file = sys.argv[1]
contents=open(file,"r")

# last_column is a list of values in the last column
last_column = contents.readline().strip().split(",")[-1]
if file == "main.csv" and last_column != "total":
    # print(contents.readline())
    print('Please run "bash submission.sh total" first')
    exit()


lines = contents.read().strip().split("\n")
#print(lines)

# data will store the marks
data=[]

for line in lines:
    last_column=line.strip().split(",")
    data.append(float(last_column[-1]))
   

# print(data)
max=sorted(data)[-1]
min=sorted(data)[0]
# print(max,min)

print("Input the maximum and minimum score possible:")
print("Min score: ", end="")
Min = float(input())
print("Max score: ", end="")
Max = float(input())

if max > Max or min < Min:
    print("Scores out of this range were achieved.")
    exit()

# print(Min,Max)

# plot_x will store 101 linearly seperated values, from Min to Max
plot_x = np.linspace(0,100,101)
# print(plot_x)

# plot_y will have the frequencies of each range 
plot_y = np.zeros(101)
for val in data:
    val_range = int(100*(val-Min)/(Max-Min))
    plot_y[val_range] += 1

plot_x *= (Max-Min)/100
plot_x += Min
# print(plot_x)
plt.plot(plot_x,plot_y, ls="-",)
plt.xlabel("Marks")
plt.ylabel("Frequency")
plt.show()