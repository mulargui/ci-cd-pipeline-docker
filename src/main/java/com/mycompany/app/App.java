package com.mycompany.app;

public class App 
{
    public static void main( String[] args )throws InterruptedException
    {
		for(int i=0; i < 10000; i++){
			System.out.println( "Hello World! Loop: " + i);
			Thread.sleep(10000);
		}
    }
}
