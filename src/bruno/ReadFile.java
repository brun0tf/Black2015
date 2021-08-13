package bruno;

import java.io.*;
import java.util.ArrayList;

public class ReadFile {

    // Metodo que le um arquivo para dentro de uma string
    public static String LoadFileToString(String filename) {
        File sourcefile = new File(filename);
        if (sourcefile.isFile()) {
            if (sourcefile.canRead()) {
                StringBuilder strBuff = new StringBuilder();
                try {
                    FileReader fReader = new FileReader(sourcefile);
                    BufferedReader p = new BufferedReader(fReader);
                    String str = p.readLine();
                    while (str != null) {
                        strBuff.append(str).append("\n");
                        str = p.readLine();
                    }
                    p.close();
                    fReader.close();
                    return strBuff.toString();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } else {
                System.out.println("\n" + "Access denied! You cannot read this file.");
            }
        }
        return null;
    }

    public static ArrayList<String> loadFileToArray (String fileName){
        File sourceFile = new File (fileName);
        ArrayList<String> outArray = new ArrayList<>();
        if (sourceFile.isFile()){
            if(sourceFile.canRead()){
                StringBuilder strBuff = new StringBuilder();
                try{
                    FileReader fReader = new FileReader(sourceFile);
                    BufferedReader p = new BufferedReader(fReader);
                    String str = p.readLine();
                    while (str != null){
                        outArray.add(str);
                        str = p.readLine();
                    }
                    p.close();
                    fReader.close();
                    return outArray;

                }catch (IOException e){
                    e.printStackTrace();
                }
            } else System.out.println("\n" + "Access denied! You cannot read this file.");
        }
        return null;
    }

}