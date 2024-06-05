package com.github.lenguyenhcm325.coursemanagementsystembackend.controller;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Course;
import com.github.lenguyenhcm325.coursemanagementsystembackend.service.CourseService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
  public ResponseEntity<Course> createCourse(@Valid @RequestBody Course course) {
    Course createdCourse = courseService.saveCourse(course);
    return new ResponseEntity<>(createdCourse, HttpStatus.CREATED);
  }

  @GetMapping("/{id}")
  public ResponseEntity<Course> getCourseById(@PathVariable int id) {
    Course course = courseService.getCourseById(id);
    if (course != null) {
      return new ResponseEntity<>(course, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @GetMapping
  public ResponseEntity<List<Course>> getAllCourses() {
    List<Course> courses = courseService.getAllCourses();
    return new ResponseEntity<>(courses, HttpStatus.OK);
  }

  @PutMapping("/{id}")
  public ResponseEntity<Course> updateCourse(
      @PathVariable int id, @Valid @RequestBody Course updatedCourse) {
    Course existingCourse = courseService.getCourseById(id);
    if (existingCourse != null) {
      Course updated = courseService.updateCourse(id, updatedCourse);
      return new ResponseEntity<>(updated, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteCourse(@PathVariable int id) {
    Course existingCourse = courseService.getCourseById(id);
    if (existingCourse != null) {
      courseService.deleteCourseById(id);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }
}
