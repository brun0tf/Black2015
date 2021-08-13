package bruno;

import java.io.*;

public class Main {

    public static void main(String[] args) throws IOException {
        FileOutputStream buffer = new FileOutputStream("src\\Bruno\\Auto\\auto.txt");
        PrintWriter autoArch = new PrintWriter(buffer);
        String caseName;
        Variables var;

        for(int i = 0, j = 0; i < args.length/5; i++, j = j + 5){
            String logicGate = ReadFile.LoadFileToString(args[j]);
            String[] inputVector = args[j+1].split("");

            Passo1 p1 = new Passo1(inputVector, args[j+2], args[j+3], logicGate, Integer.parseInt(args[j+4]));
            caseName = p1.makeNetlist();

            runSPICE("src\\Bruno\\Output\\Passo1_" + caseName + ".sp");

            Passo2 p2 = new Passo2(inputVector, args[j+2], args[j+3], logicGate, Integer.parseInt(args[j+4]), caseName);
            var = p2.makeNetlist();

            runSPICE("src\\Bruno\\Output\\Passo2_" + caseName + ".sp");

            Passo3 p3 = new Passo3(inputVector, args[j+2], args[j+3], logicGate, Integer.parseInt(args[j+4]), caseName, var, "25f");
            p3.makeNetlist();

            runSPICE("src\\Bruno\\Output\\Passo3_" + caseName + ".sp");

        }




        //String teste = ReadFile.LoadFileToString("src\\Bruno\\Output\\Passo1_AOI21_111_VDDtoOUT.log");
        //System.out.println(teste);

        autoArch.close();
    }

    public static void runSPICE (String pathNETLIST) throws IOException { //https://docs.oracle.com/javase/7/docs/api/java/lang/ProcessBuilder.html
        String runSPICE_command = "tspcmd64.exe";

        ProcessBuilder test = new ProcessBuilder(runSPICE_command, pathNETLIST);
        test.redirectErrorStream(true);
        Process p = test.start();

        BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String line;
        while (true) {
            line = r.readLine();
            if (line == null) { break; }
            System.out.println(line);
        }
    }



}
