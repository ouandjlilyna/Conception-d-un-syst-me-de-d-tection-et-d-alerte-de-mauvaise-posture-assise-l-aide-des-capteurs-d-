#!/usr/bin/env python
# coding: utf-8

# In[1]:


#
import serial
ser = serial.Serial('COM6', 112500, timeout=1)
b = True

#file_path = open('ml_model', 'rb')     
#model = pickle.load(file_path)

with open('mauvaise_position20.csv','wb') as f:
    f.write("data\n".encode())
    while b:
        line = ser.readline()
        if line:
 
           n = [int(s) for s in line.split() if s.isdigit()]
           if len(n) != 0:
                print(str(n[0]))
                
                f.write(str(n[0]).encode())
                f.write("\n".encode())
ser.close()              


# In[5]:


import serial
import pandas as pd
import pickle
from keras.models import load_model
#from pynput.keyboard import Key, Controller

def generate_input_data(device_data,gender,age):
    df = pd.DataFrame(device_data, columns =['data'])
    #print(df)     
    df['data'] = pd.to_numeric(df['data'])    

    max = df['data'].max()
    min = df['data'].min()
    mean = df['data'].mean()
    std = df['data'].std() 
    var = df['data'].var()
    
    #print([max, min, mean, std, var, age, gender])
    return [[max, min, mean, std, var, age, gender]]

ser = serial.Serial('COM6', 112500, timeout=1)

b = True

file_path = open('KNN_model', 'rb')     
model = pickle.load(file_path)
#model=load_model('DL2.h5')


data=[]
idx=0

while b:
    line = ser.readline()  
    if line:
        
        if str(line)[2] == ' ':
            
            age = int(str(line)[3] +str(line)[4])  ;
            print('age ',age)

        elif str(line)[2] == 'F' :

            gender = 1 ;
            print('gender',gender)
            
        elif str(line)[2] == 'M' :    
            gender = 0 ;
            print('gender ',gender)
                
        else :
            n = [int(s) for s in line.split() if s.isdigit()]

            if len(n) != 0:
                
                data.append(str(n[0]))      
                idx += 1
            if idx == 300:
                p = model.predict(generate_input_data(data,gender,age))
                print("Bonne Position" if p[0]==0 else "Mauvaise Position")
                #print("Bonne Position" if abs(p[0])<0.5 else "Mauvaise Position")
                
               
                #if abs(p[0])<0.5:
                if p[0]==0:
                    ser.write(b'Bonne\r')             
                else:
                    ser.write(b'Mauvaise\r')
                data = []
                idx = 0
                
              


# In[ ]:




