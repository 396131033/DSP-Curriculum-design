global neurosky_scom

try
fclose(neurosky_scom);
catch err
    msgbox('���ڹر�ʧ�ܣ�');
    return
end
delete(neurosky_scom);