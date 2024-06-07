package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Course;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.CourseRepository;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CourseService {

  private final CourseRepository courseRepository;
  private final EntityManager entityManager;

  @Autowired
  public CourseService(CourseRepository courseRepository, EntityManager entityManager) {
    this.courseRepository = courseRepository;
    this.entityManager = entityManager;
  }

  @Transactional
  public Course saveCourse(Course course) {
    Course savedCourse = courseRepository.save(course);
    entityManager.refresh(savedCourse);
    return savedCourse;
  }

  public Course getCourseById(int id) {
    return courseRepository.findById(id).orElse(null);
  }

  @Transactional
  public void deleteCourseById(int id) {
    courseRepository.deleteById(id);
  }

  @Transactional
  public Course updateCourseById(int id, Course updatedCourse) {
    return courseRepository
        .findById(id)
        .map(
            foundCourse -> {
              foundCourse.setTitle(updatedCourse.getTitle());
              foundCourse.setAuthor(updatedCourse.getAuthor());
              foundCourse.setProgress(updatedCourse.getProgress());
              foundCourse.setCourseProfileImageLink(updatedCourse.getCourseProfileImageLink());
              foundCourse.setNotes(updatedCourse.getNotes());
              foundCourse.setDescription(updatedCourse.getDescription());
              foundCourse.setStartDate(updatedCourse.getStartDate());
              foundCourse.setEndDate(updatedCourse.getEndDate());
              foundCourse.setProvider(updatedCourse.getProvider());
              foundCourse.setCategories(updatedCourse.getCategories());
              entityManager.flush();
              entityManager.refresh(foundCourse);
              return foundCourse;
            })
        .orElse(null);
  }

  public List<Course> getAllCourses() {
    return courseRepository.findAll();
  }
}
