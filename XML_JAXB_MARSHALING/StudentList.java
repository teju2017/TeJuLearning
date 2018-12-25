package com.maven.work;

import java.util.*;
import javax.xml.bind.annotation.*;


@XmlRootElement
public class StudentList {

	
	private ArrayList<Student> stud;
	private String schname;
	private String city;
	
	/*public StudentList() {
		System.out.println("Created initially for a list of Students");
	}*/
	
	public void setStudlist(ArrayList<Student> stud)
	{
		this.stud=stud;
	}
	
	public ArrayList<Student> getStudlist()
	{
		return stud; 
	}
	
	public void setschool(String schname)
	{
		this.schname=schname;
	}
	@XmlElement
	public String getschool()
	{
		return schname;
	}
	
	public void setcity(String city)
	{
		this.city=city;
	}
	
	//@XmlElement
	public String getcity()
	{
		return city;
	}
	
	public void adddetails(Student std)
	{
		try
		{
			if(stud==null)
			{
				stud=new ArrayList<Student>();
			}
			stud.add(std);
		}
		catch(Exception ae)
		{
			System.out.println("Exception value is "+ae.getMessage());
		}
	}
	


}
