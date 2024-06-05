package com.github.lenguyenhcm325.coursemanagementsystembackend.controller;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Course;
import com.github.lenguyenhcm325.coursemanagementsystembackend.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/courses")
public class CourseController {

  private final CourseService courseService;

  @Autowired
  public CourseController(CourseService courseService) {
    this.courseService = courseService;
  }

  @PostMapping
  public Course createCourse(@RequestBody Course course) {
    return courseService.saveCourse(course);
  }

  @GetMapping("/{id}")
  public Course getCourseById(@PathVariable int id) {
    return courseService.getCourseById(id);
  }

  @GetMapping
  public List<Course> getAllCourses() {
    return courseService.getAllCourses();
  }

  @PutMapping("/{id}")
  public Course updateCourse(@PathVariable int id, @RequestBody Course updatedCourse) {
    return courseService.updateCourse(id, updatedCourse);
  }

  @DeleteMapping("/{id}")
  public void deleteCourse(@PathVariable int id) {
    courseService.deleteCourseById(id);
  }
}
