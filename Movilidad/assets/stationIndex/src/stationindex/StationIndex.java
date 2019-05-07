/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package stationindex;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

/**
 *
 * @author JSANCHEZAGU
 */
public class StationIndex {

    public static double norm(double x1, double y1, double x2, double y2){
        return Math.sqrt(Math.pow(x1-x2,2) + Math.pow(y1-y2, 2));
    }
    
    public void printA(String a[]){
        for (int i = 0; i < a.length; i++) {
            System.out.print(a[i] + " ");
        }
        System.out.print("\n");
    }
    
    public void printA2(ArrayList a){
        for (int i = 0; i < a.size(); i++) {
            printA((String[]) a.get(i));
        }
        System.out.println("\n");
    }
    
    public void ordenaEstaciones(String arch, String sistema) throws FileNotFoundException, IOException{
        File file = new File(arch);
        Scanner sc = new Scanner(file); 
        ArrayList<String[]> stations = new ArrayList<>();
        ArrayList<String[]> orden = new ArrayList<>(); 
        while (sc.hasNextLine()) 
            stations.add(sc.nextLine().split(",",4)); 
        orden.add(stations.get(0));
        stations.remove(stations.get(0));
        int i = 0;
        while(stations.size() > 0 && i < orden.size()){
            String pivote[] = orden.get(orden.size()-1);
            String min[] = null;
            double normin = 1000;
            double norma = 0;
            for (int j = 0; j < stations.size(); j++) {
                double x1 = Double.parseDouble(pivote[1]);
                double y1 = Double.parseDouble(pivote[2]);
                double x2 = Double.parseDouble(stations.get(j)[1]);
                double y2 = Double.parseDouble(stations.get(j)[2]);
                norma = StationIndex.norm(x1,y1,x2,y2);
                //System.out.println("Norma de:" + pivote[0] + " y " + stations.get(j)[0] + " " +norma);

                if (norma < normin){
                    normin = norma;
                    min = stations.get(j);
                }
            }
            //System.out.println("MINIMO: " + min[0]);
            orden.add(min);
            stations.remove(min);
            i++;
            //System.out.println("=============================");
        }
        //printA2(orden);
        String res = imprimeIndice(sistema, orden);
        System.out.println(res);
    }
    
    public String imprimeIndice(String sistema, ArrayList orden){
        String res = "";
        for (int i = 0; i < orden.size(); i++) {
            res += sistema + '(';
            for (String s : (String[])orden.get(i)) {
                res += s + ',';
            }
            res += (i + 1) + ").\n";
        }
        return res;
    }
    
    public static void main(String[] args) throws IOException {
        StationIndex s = new StationIndex();
        /**
         * Metrobus
        System.out.println("%Linea 1");
        s.ordenaEstaciones("L1.txt", "mb");
        System.out.println("%Linea 2");
        s.ordenaEstaciones("L2.txt", "mb");
        System.out.println("%Linea 3");
        s.ordenaEstaciones("L3.txt", "mb");
        System.out.println("%Linea 4");
        s.ordenaEstaciones("L4.txt", "mb");
        System.out.println("%Linea 5");
        s.ordenaEstaciones("L5.txt", "mb");
        System.out.println("%Linea 6");
        s.ordenaEstaciones("L6.txt", "mb");
        *
        */

        System.out.println("%Linea 1");
        s.ordenaEstaciones("L1.txt", "metro");



    }

}
