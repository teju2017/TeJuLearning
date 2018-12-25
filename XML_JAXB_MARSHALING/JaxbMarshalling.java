package com.maven.work;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import java.io.*;
import java.util.ArrayList;

public class JaxbMarshalling {
	
	

	public JaxbMarshalling(File fil) {
		if(fil.exists())
		{
			fil.delete();
		}
	   System.out.println("Just started doing the Marshaling");
	   
	}
	
	public void filecheck(File filename)
	{
		if(filename.exists())
		{
			System.out.println("XML FILE CREATION SUCCESSFUL");
		}
		else
		{
			System.out.println("Failed to create the file");
		}
	}

	
	public static void main(String args[])
	{
	
		String XML_FILE_NAME="C:/Homework/Student.xml";
		File filename=new File(XML_FILE_NAME);
		JaxbMarshalling abc = new JaxbMarshalling(filename);
		 try{

	    //creating the JAXB context, JAXB context needs to be created on the class that forms the root element

	     JAXBContext jContext = JAXBContext.newInstance(StudentList.class);

	    //creating the marshaller object from the Jaxbcontext

	    Marshaller marshallObj = jContext.createMarshaller();

	    //setting the property to show xml format output

	    marshallObj.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);

	    //setting the values in POJO class

	    Student student = new Student("abhishek",1163,"hadoop","Beginner");
	    Student Student1 = new Student("Tejas",2000,"AWS","Intermediate");
	    Student Student2 = new Student("Morshe",3000,"IT admin","Excellent");
	    
	    // Adding the pojo class objects using a method in the StudentList class on which the context is available 
	    
	    StudentList lst = new StudentList();
	    lst.adddetails(student);
	    lst.adddetails(Student1);
	    lst.adddetails(Student2);
	    lst.setschool("Aravinda");
	    lst.setcity("Hassan");

	    //calling the marshall method for the Creation of the XML
	    
	    
	    marshallObj.marshal(lst,new FileOutputStream(filename));
	    abc.filecheck(filename);
	    
	    
	    

	} 
		 
	catch(Exception e) {

	    e.printStackTrace();

	}
	}
}

