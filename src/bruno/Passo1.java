package bruno;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.StringTokenizer;

public class Passo1 {
    private final String[] inputVector;
    private final String terminal1, terminal2, logicGate;
    private final int fanOut;

    public Passo1(String[] inputVector, String terminal1, String terminal2, String logicGate, int fanOut) {
        this.inputVector = inputVector;
        this.terminal1   = terminal1;
        this.terminal2   = terminal2;
        this.logicGate   = logicGate;
        this.fanOut      = fanOut;
    }

    public String makeNetlist () throws FileNotFoundException {
        FileOutputStream buffer;
        ArrayList<String> input;
        String caseName = getLogicGateName(logicGate) + "_" + arrayToString(inputVector) + "_"+ terminal1.toUpperCase() + "to" + terminal2.toUpperCase() +"_FO"+ this.fanOut;
        String fileNameSP = "src\\bruno\\Output\\" + "Passo1_"+ getLogicGateName(logicGate) + "_" + arrayToString(inputVector) + "_"+ terminal1.toUpperCase() + "to" + terminal2.toUpperCase() +"_FO"+ this.fanOut +".sp";
        buffer = new FileOutputStream(fileNameSP);

        PrintWriter arch = new PrintWriter(buffer);

        arch.println("""
                
                .include ptm_90nm.l
                .param 'supply' = 1.2
                +\t'lambda' = 1.8087
                +\t'widthPmos' = '200n*lambda'
                +\t 'iTotal'  = 20u
                V1\t\tVDD  \t\t0\t\tDC\t\tsupply
                V2\t\tVDD2  \t0\t\tDC\t\tsupply
                vinA \thigh\t0\tPWL(0ns 0\t\t1ns\t\t0\t\t1.001ns\tsupply)
                vinB \tlow\t\t0\tPWL(0ns supply\t1ns\t\tsupply\t1.001ns\t0)

                .subckt inverter in out VDD GND\s
                MP1\tVDD\tin\tout\tVDD pmos\tL = 90n  W = 'widthPmos'\t
                MN2\tGND\tin\tout\tGND nmos\tL = 90n  W = 200n\t\t
                .ends inverter
                """);

        arch.println(logicGate+ "\n");

        input = convertInputVectorToHighOrLow(inputVector);

        arch.print("Xdut\t");
        for(String x : input)
            arch.print(x+"\t");
        arch.print("\t" + "outDUT\tVDD\tGND\t"+ getLogicGateName(logicGate)+"\n");

        arch.println("iS\tXdut." + terminal1 + "\tXdut." + terminal2 + "\t0\texp\t(0\t'iTotal'\t2n\t2p\t2.015n\t1p)\n");

        for (int i = 0; i < fanOut; i++)
            arch.println("Xinv" + i + "\toutDut\tvoid\tVDD\tGND\tinverter");




        if(vPeak(terminal1, terminal2) == 1.2)
            arch.println("\n.measure\ttran\tVpeak\tmax\tv(Xdut."+ targetNode(terminal1, terminal2) + ")\t from = 1.5ns to = 3ns");
        else
            arch.println(".measure\ttran\tVpeak\tmin\tv(Xdut."+ targetNode(terminal1, terminal2) + ")\t from = 1.5ns to = 3ns");



        arch.println("\n.model\toptmod\topt\titropt = 40\n.optimize\topt2\tmodel=optmod\tanalysisname=tran\n.optgoal\topt2\tvPeak" + " = " + vPeak(terminal1, terminal2));
        arch.println(".paramlimits opt2 'iTotal' minval=20u maxval=2m\n");

        arch.println(".measure tran avgiS\t\t\tavg i(iS) from = 2ns to = 2.4ns\n" + ".measure tran cargaTotal\tparam = 'avgiS * 0.4n'");
        //arch.println(".measure tran iTotalPeak param = 'iTotal'");

        arch.println(".print v(outDUT)");
        arch.println("\n.tran\t1p\t5ns\n.end");

        arch.close();
        return caseName;
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

    public String targetNode (String terminal1, String terminal2){
        if(!terminal1.equals("GND") && !terminal1.equals("VDD")) return terminal1;
        return terminal2;
    }

    public double vPeak (String terminal1, String terminal2){
        if(terminal1.equals("GND") || terminal2.equals("GND")) return 0.0;
        return 1.2;
    }

    public String arrayToString (String[] inputVector){
        StringBuilder sb = new StringBuilder();
            for (String x : inputVector)
                sb.append(x);
        return sb.toString();
    }

}
