package com.maven.work;

//* This POJO class determines the tags that will come up in the element section of the XML
//* any new tag needs a modification in this class to add the variable and tags


import javax.xml.bind.annotation.*;

import java.util.*;

@XmlRootElement

public class Student {

	    private String name;

	    private int id;

	    private String subject;
	    
	    private String proficiency;

public Student(){

	    }

	    Student(String name,int id,String subject,String proficiency){

	        this.name=name;

	        this.id=id;

	        this.subject=subject;
	        
	        this.proficiency=proficiency;

	    }

	    @XmlElement

	    public String getName() {

	        return name;

	    }

	    public void setName(String name) {

	        this.name = name;

	    }

	    @XmlAttribute

	    public int getId() {

	        return id;

	    }

	    public void setId(int id) {

	        this.id = id;

	    }

	    @XmlElement

	    public String getSubject() {

	        return subject;

	    }

	    public void setSubject(String subject) {

	        this.subject = subject;

	    }
	    
	    public void  setprofeciency(String Proficiency)
	    {
	        this.proficiency=Proficiency;
	    }
	    
	    public String getprofeciency()
	    {
	    	return proficiency;
	    }
	    
	    

	}
	
