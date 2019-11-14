function write_L1_corr_data_files(metadataFilePath)

command1 = '/home/cmunoz/workspace/virtualenvs/salinity-corrections-writer/bin/python';
command2 = '/home/cmunoz/Documents/programming/PythonScripts/salinity-corrections-writer/lib/main.py';

system([command1 ' ' command2 ' ' metadataFilePath])

end