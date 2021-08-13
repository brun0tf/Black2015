package bruno;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.StringTokenizer;

public class Passo2 {
    private final String[] inputVector;
    private String terminal1, terminal2, logicGate, caseName;
    private final int fanOut;

    public Passo2(String[] inputVector, String terminal1, String terminal2, String logicGate, int fanOut, String caseName) {
        this.inputVector = inputVector;
        this.terminal1   = terminal1;
        this.terminal2   = terminal2;
        this.logicGate   = logicGate;
        this.fanOut      = fanOut;
        this.caseName    = caseName;
    }

    public Variables makeNetlist() throws FileNotFoundException {
        Variables var = getVariablesFromPasso1();

        FileOutputStream buffer = new FileOutputStream("D:\\pesquisa\\Projeto SEE\\Algoritmos\\MeuModelo\\src\\bruno\\Output\\" + "Passo2_" + this.caseName + ".sp");
        PrintWriter arch = new PrintWriter(buffer);

        arch.println("\n.include ptm_90nm.l\n" +
                ".param 'supply' = 1.2\n" +
                "+\t'lambda' = 1.8087\n" +
                "+\t'widthPmos' = '200n*lambda'\n" +
                "+\t'iTotal' = " + var.getiTotal() + "\n" +
                "+\t'iHold' = 20u\n" +
                "+\t'iPrompt' = (iTotal - iHold)\n" +
                "V1\t\tVDD  \t\t0\t\tDC\t\tsupply\n" +
                "V2\t\tVDD2  \t0\t\tDC\t\tsupply\n" +
                "\n" +
                "vinA \thigh\t0\tPWL(0ns 0\t\t1ns\t0\t\t\t1.001ns\tsupply)\n" +
                "vinB \tlow\t0\tPWL(0ns supply\t1ns\tsupply\t1.001ns\t0)\n" +
                "\n" +
                ".subckt inverter in out VDD GND \n" +
                "MP1\tVDD\tin\tout\tVDD pmos\tL = 90n  W = 'widthPmos'\t\n" +
                "MN2\tGND\tin\tout\tGND nmos\tL = 90n  W = 200n\t\t\n" +
                ".ends inverter\n\n" +
                logicGate + ""
        );

        ArrayList<String> input = convertInputVectorToHighOrLow(inputVector);

        arch.print("Xdut   ");
        for(String x : input)
            arch.print(x+"\t");

        arch.print("\t" + "outDUT\tVDD\tGND\t"+ getLogicGateName(logicGate)+"\n" +
                "iSp\tXdut." + terminal1 + "\tXdut." + terminal2 + "\t0\texp\t(0\t'iPrompt'\t2n\t2p\t2.015n\t1p)\n" +
                "iSh\tXdut." + terminal1 + "\tXdut." + terminal2 + "\t0\texp\t(0\t'iHold'\t2n\t2p\t2.1n\t4p)\n"
        );

        for (int i = 0; i < fanOut; i++)
            arch.println("Xinv" + i + "\toutDut\tvoid\tVDD\tGND\tinverter");

        String myGoal;
        if(vPeak() == 1.2) {
            myGoal = "Min";
            arch.println("\n.measure\ttran\tsetTracker\tmax\tv(Xdut."+ targetNode() + ")\t from = 2.0ns to = 2.1ns\n");
        }
        else {
            arch.println("\n.measure\ttran\tsetTracker\tmin\tv(Xdut." + targetNode() + ")\t from = 2.0ns to = 2.1ns\n");
            myGoal = "Max";
        }

        arch.println("\n.measure\ttran\tvPeakMin\tmin\tv(Xdut."+ targetNode() + ")\t from = 2.04ns to = 2.1ns\n");
        arch.println(".measure\ttran\tvPeakMax\tmax\tv(Xdut."+ targetNode() + ")\t from = 2.04ns to = 2.1ns\n");

        arch.println(
                ".model \t\t optmod opt level=1 itropt=40\n" +
                ".optimize \t opt2 model=optmod analysisname=tran\n" +
                ".optgoal     opt2 VPeak"+ myGoal + " = "  + vPeak() + "\n" +
                ".paramlimits opt2 'iHold' minval=20u maxval=2m\n"
        );

        arch.println(
                """
                 .measure tran avgPrompt\t\t\tavg i(iSp) from = 2ns to = 2.4ns
                 .measure tran cargaPrompt\t\tparam = 'avgPrompt * 0.4n'
                 .measure tran avgHold\t\t\tavg i(iSh) from = 2ns to = 2.4ns
                 .measure tran cargaHold\t\tparam = 'avgHold * 0.4n'"""
        );

        arch.println("\n.print v(outDUT) v(Xdut." + targetNode() + ")" +"\n.print i(iSh) i(iSp)");
        arch.println("\n.tran\t1p\t5ns\n.end");
        arch.close();
        return var;
    }



    public Variables getVariablesFromPasso1 (){
        ArrayList<String> line = ReadFile.loadFileToArray("src\\Bruno\\Output\\" + "Passo1_" + this.caseName + ".log");
        Variables v = new Variables();
        String temp_iTotal_line = null, temp_cargaTotal_line = null, temp_Vpeak_line = null;

        assert line != null;
        for (String x : line){
            if (x.contains("iTotal")) temp_iTotal_line = x;
            else if (x.contains("cargaTotal")) temp_cargaTotal_line = x;
            else if (x.contains("Vpeak"))   temp_Vpeak_line = x;
        }

        v.setiTotal(getValueOfVariable(temp_iTotal_line));
        v.setQcoll(getValueOfVariable(temp_cargaTotal_line));
        v.setvPeak(getValueOfVariable(temp_Vpeak_line));

        if(vPeak() == 1.2) {
            if (v.getvPeak() > 1.25 || v.getvPeak() < 1.19) System.out.println("problemas com o passo 1...");
            else System.out.println(caseName + " Passo 1 " +"(FO" + fanOut +"): Vpeak = " + v.getvPeak() + "; ótimo...");
        }
        else if (vPeak() == 0.0){
            if (v.getvPeak() > 0.1 || v.getvPeak() < -0.5) System.out.println("problemas com o passo 1...");
            else System.out.println(caseName + " Passo 1 " +"(FO" + fanOut +"): Vpeak = " + v.getvPeak() + "; ótimo...");
        }

        return v;
    }


    public double getValueOfVariable (String line){
        StringTokenizer sT = new StringTokenizer(line, "= ");
        sT.nextToken();
        return Double.parseDouble(convertUnityofMeasuremeant(sT.nextToken()));
    }

    public String convertUnityofMeasuremeant (String line){
        if(line.contains("m")) return line.replace("m", "E-3");
        if(line.contains("u")) return line.replace("u", "E-6");
        if(line.contains("n")) return line.replace("n", "E-9");
        if(line.contains("p")) return line.replace("p", "E-12");
        if(line.contains("f")) return line.replace("f", "E-15");
        if(line.contains("a")) return line.replace("a", "E-18");
        else return line;
    }

    public ArrayList<String> convertInputVectorToHighOrLow (String [] inputVector){
        ArrayList <String> x = new ArrayList<>();
        for (String a : inputVector){
            if (a.equals("1")) x.add("high");
            else if (a.equals("0")) x.add("low");
        }
        return x;
    }

    public String getLogicGateName (String logicGate){
        StringTokenizer firstLine = new StringTokenizer(logicGate, " ");
        firstLine.nextToken();
        return firstLine.nextToken();
    }

    public double vPeak ( ){
        if(this.terminal1.equals("GND") || this.terminal2.equals("GND")) return 0.0;
        return 1.2;
    }

    public String targetNode (){
        if(!terminal1.equals("GND") && !terminal1.equals("VDD")) return terminal1;
        return terminal2;
    }
}
