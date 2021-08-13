package bruno;

public class Variables {
    private double iTotal, iHoldPeak, iPromptPeak, Qcoll, Qprompt, Qhold, vPeak;

    public double getvPeak() {
        return vPeak;
    }

    public void setvPeak(double vPeak) {
        this.vPeak = vPeak;
    }

    public double getiTotal() {
        return iTotal;
    }

    public void setiTotal(double iTotal) {
        this.iTotal = iTotal;
    }

    public double getiHoldPeak() {
        return iHoldPeak;
    }

    public void setiHoldPeak(double iHoldPeak) {
        this.iHoldPeak = iHoldPeak;
    }

    public double getiPromptPeak() {
        return iPromptPeak;
    }

    public void setiPromptPeak(double iPromptPeak) {
        this.iPromptPeak = iPromptPeak;
    }

    public double getQcoll() {
        return Qcoll;
    }

    public void setQcoll(double qcoll) {
        Qcoll = qcoll;
    }

    public double getQprompt() {
        return Qprompt;
    }

    public void setQprompt(double qprompt) {
        Qprompt = qprompt;
    }

    public double getQhold() {
        return Qhold;
    }

    public void setQhold(double qhold) {
        Qhold = qhold;
    }
}
