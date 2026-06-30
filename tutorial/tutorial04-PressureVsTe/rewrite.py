f = open('RF_Plasma_WithOut_Metastables-1Torr-testing-rename.i','r')
filedata = f.read()
f.close()

newdata = filedata.replace("${fparse 0.05 * pressure_og}","${fparse 10.0 * pressure_og}")

f = open('RF_Plasma_WithOut_Metastables-1Torr-testing-rename.i','w')
f.write(newdata)
f.close()
