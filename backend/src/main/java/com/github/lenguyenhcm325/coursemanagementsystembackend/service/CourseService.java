package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Course;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.CourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CourseService {

  private final CourseRepository courseRepository;

  @Autowired
  public CourseService(CourseRepository courseRepository) {
    this.courseRepository = courseRepository;
  }

  public Course saveCourse(Course course) {
    return courseRepository.save(course);
  }

  public Course getCourseById(int id) {
    return courseRepository.findById(id).orElse(null);
  }
}
