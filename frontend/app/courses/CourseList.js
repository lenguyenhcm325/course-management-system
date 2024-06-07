"use client";

import { useState, useEffect } from "react";
import axios from "axios";
import styles from "./CourseList.module.css";
import EditCourseForm from "./EditCourseForm";

const CourseList = ({ courses, onCourseUpdated, refreshCourses }) => {
  const [editingCourse, setEditingCourse] = useState(null);
  const [sortedCourses, setSortedCourses] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [coursesPerPage] = useState(10);

  useEffect(() => {
    const sorted = [...courses].sort(
      (a, b) => new Date(b.updatedAt) - new Date(a.updatedAt)
    );
    setSortedCourses(sorted);
  }, [courses]);

  const handleEditClick = (course) => {
    setEditingCourse(course);
  };

  const handleDeleteClick = async (courseId) => {
    if (window.confirm("Are you sure you want to delete this course?")) {
      try {
        await axios.delete(`http://localhost:8080/courses/${courseId}`);
        refreshCourses();
      } catch (error) {
        console.error("There was an error deleting the course!", error);
      }
    }
  };

  const handleSave = async (updatedCourse) => {
    await onCourseUpdated(updatedCourse);
    setEditingCourse(null);
    refreshCourses();
  };

  const handleCancel = () => {
    setEditingCourse(null);
  };

  const indexOfLastCourse = currentPage * coursesPerPage;
  const indexOfFirstCourse = indexOfLastCourse - coursesPerPage;
  const currentCourses = sortedCourses.slice(
    indexOfFirstCourse,
    indexOfLastCourse
  );

  const paginate = (pageNumber) => setCurrentPage(pageNumber);

  const pageNumbers = [];
  for (let i = 1; i <= Math.ceil(sortedCourses.length / coursesPerPage); i++) {
    pageNumbers.push(i);
  }

  return (
    <div>
      {sortedCourses.length === 0 ? (
        <p className={styles.noCoursesMessage}>
          You have no courses, click 'Add Course' to add a course!
        </p>
      ) : (
        <>
          <ul className={styles.courseList}>
            {currentCourses.map((course) => (
              <li key={course.id} className={styles.courseItem}>
                <h2>{course.title}</h2>
                <p>
                  <span>Author:</span> {course.author}
                </p>
                <p>
                  <span>Provider:</span> {course.provider.name}
                </p>
                <p>
                  <span>Notes: </span>
                  <a href={course.notes} className={styles.notesLink}>
                    View notes
                  </a>
                </p>
                <p>
                  <span>Categories:</span>{" "}
                  {course.categories
                    .map((category) => category.name)
                    .join(", ")}
                </p>
                <p>
                  <span>Progress:</span> {course.progress}%
                </p>
                <button onClick={() => handleEditClick(course)}>Edit</button>
                <button
                  onClick={() => handleDeleteClick(course.id)}
                  className={styles.deleteButton}
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
          {editingCourse && (
            <EditCourseForm
              course={editingCourse}
              onSave={handleSave}
              onCancel={handleCancel}
            />
          )}
          <nav className={styles.pagination}>
            {pageNumbers.map((number) => (
              <button
                key={number}
                onClick={() => paginate(number)}
                className={`${styles.pageItem} ${
                  currentPage === number ? styles.active : ""
                }`}
              >
                {number}
              </button>
            ))}
          </nav>
        </>
      )}
    </div>
  );
};

export default CourseList;
