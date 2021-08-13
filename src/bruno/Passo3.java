package bruno;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.StringTokenizer;

public class Passo3 {
    private final String[] inputVector;
    private String terminal1, terminal2, logicGate, caseName;
    private final int fanOut;
    private final Variables var;
    private final String Qcoll;

    public Passo3 (String[] inputVector, String terminal1, String terminal2, String logicGate, int fanOut, String caseName, Variables var, String Qcoll) {
        this.inputVector = inputVector;
        this.terminal1 = terminal1;
        this.terminal2 = terminal2;
        this.logicGate = logicGate;
        this.caseName = caseName;
        this.fanOut = fanOut;
        this.var = var;
        this.Qcoll = Qcoll;
    }
    public void makeNetlist() throws FileNotFoundException {
        getVariablesFromPasso2();
        FileOutputStream buffer = new FileOutputStream("src\\bruno\\Output\\" + "Passo3_" + this.caseName + ".sp");
        PrintWriter arch = new PrintWriter(buffer);

        arch.println("\n.include ptm_90nm.l\n" +
                ".param 'supply' = 1.2\n" +
                "+\t'lambda' = 1.8087\n" +
                "+\t'widthPmos' = '200n*lambda'\n" +
                "+\t'iTotal' = " + var.getiTotal() + "\n" +
                "+\t'iHold' = "+ var.getiPromptPeak() + "\n" +
                "+\t'iPrompt' = (iTotal - iHold)\n" +
                "+\t 'tF_delay' = 2n\n\n" +
                "V1\t\tVDD   \t0\t\tDC\t\tsupply\n" +
                "V2\t\tVDD2  \t0\t\tDC\t\tsupply\n" +
                "\n" +
                "vinA \thigh\t0\tPWL(0ns 0\t   \t1ns\t0\t   \t1.001ns\tsupply)\n" +
                "vinB \tlow \t0\tPWL(0ns supply\t1ns\tsupply\t1.001ns\t0)\n" +
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
                "iSh\tXdut." + terminal1 + "\tXdut." + terminal2 + "\t0\texp\t(0\t'iHold'\t2n\t2p\t'tF_delay'\t4p)\n"
        );

        for (int i = 0; i < fanOut; i++)
            arch.println("Xinv" + i + "\toutDut\tvoid\tVDD\tGND\tinverter");

        arch.println(
                """
                 \n.measure tran avgPrompt\t\t\tavg i(iSp) from = 2ns to = 2.4ns
                 .measure tran cargaPrompt\t\tparam = 'avgPrompt * 0.4n'
                 .measure tran avgHold\t\t\tavg i(iSh) from = 2ns to = 2.4ns
                 .measure tran cargaHold\t\tparam = 'avgHold * 0.4n'\n"""
        );

        arch.println(
                ".model \t\t optmod opt level=1 itropt=40\n" +
                ".optimize \t opt2 model=optmod analysisname=tran\n" +
                ".optgoal     opt2 cargaHold = " + Qcoll + "\n" +
                ".paramlimits opt2 'tF_delay' minval=2n maxval=3n\n"
        );

        arch.println("\n.print v(outDUT)\n.print i(iSh) i(iSp)");
        arch.println("\n.tran\t1p\t5ns\n.end");
        arch.close();
    }
    public void getVariablesFromPasso2 (){
        ArrayList<String> line = ReadFile.loadFileToArray("src\\Bruno\\Output\\" + "Passo2_" + this.caseName + ".log");
        String temp_iHold_line = null, temp_cargaPrompt_line = null, temp_vPeak_line = null;
        double vPeakMin, vPeak;

        assert line != null;
        for (String x : line){
            if (x.contains("iHold")) temp_iHold_line = x;
            else if (x.contains("cargaPrompt")) temp_cargaPrompt_line = x;
            else if (x.contains("setTracker")) temp_vPeak_line = x;
        }
        this.var.setiHoldPeak(getValueOfVariable(temp_iHold_line));
        this.var.setQprompt(getValueOfVariable(temp_cargaPrompt_line));
        this.var.setiPromptPeak( this.var.getiTotal() - this.var.getiHoldPeak());

        vPeak = getValueOfVariable(temp_vPeak_line);

        testingPasso2(vPeak);


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

    public String targetNode (String terminal1, String terminal2){
        if(!terminal1.equals("GND") && !terminal1.equals("VDD")) return terminal1;
        return terminal2;
    }

    public void testingPasso2 (double vPeak){
        if(vPeak() == 1.2){
            if(vPeak > 1.35) System.out.println(""+caseName + " Passo 2" + " (FO" + this.fanOut + "): vPeak = "+ vPeak +"; me parece alto d+....\n");
            //else if (vPeakMin < 1.15) System.out.println(""+caseName+": vPeakMin menor que 1.15:" + vPeakMin + "\n");
            else System.out.println("" + caseName + " Passo 2" + " (FO" + this.fanOut + "): vPeak = "+ vPeak +"; parece bom!\n");
        }
        else if (vPeak() == 0.0){
            if(vPeak < -0.15) System.out.println("" + caseName + " Passo 2" + " (FO" + this.fanOut + "): vPeak = "+ (vPeak*-1+1.2)/1.2 +"; me parece alto d+....\n"); //(vPeak*-1+1.2)/1.2
            else System.out.println("" + caseName + " Passo 2" + " (FO" + this.fanOut + "): vPeak = "+(vPeak*-1+1.2)/1.2 +"; parece bom!\n");
        }
    }

}
