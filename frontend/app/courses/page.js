"use client";

import axios from "axios";
import { useEffect, useState } from "react";
import CourseList from "./CourseList";
import AddCourseForm from "./AddCourseForm";
import AddCategoryForm from "./AddCategoryForm";
import styles from "./Page.module.css";

const CoursesPage = () => {
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddCourseForm, setShowAddCourseForm] = useState(false);
  const [showAddCategoryForm, setShowAddCategoryForm] = useState(false);

  const fetchCourses = async () => {
    try {
      const response = await axios.get("http://localhost:8080/courses");
      setCourses(response.data);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCourses();
  }, []);

  const handleCourseAdded = (newCourse) => {
    setCourses([...courses, newCourse]);
    setShowAddCourseForm(false);
  };

  const handleCourseUpdated = async (updatedCourse) => {
    await axios.put(
      `http://localhost:8080/courses/${updatedCourse.id}`,
      updatedCourse
    );
    fetchCourses();
  };

  const handleCategoryAdded = (newCategory) => {
    setShowAddCategoryForm(false);
  };

  const handleCancelCourseForm = () => {
    setShowAddCourseForm(false);
  };

  const handleCancelCategoryForm = () => {
    setShowAddCategoryForm(false);
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className={styles.container}>
      <h1>Courses</h1>
      <div className={styles.buttonContainer}>
        <button
          className={styles.toggleButton}
          onClick={() => setShowAddCourseForm(true)}
        >
          Add Course
        </button>
        <button
          className={styles.toggleButton}
          onClick={() => setShowAddCategoryForm(true)}
        >
          Add Category
        </button>
      </div>
      {showAddCourseForm && (
        <AddCourseForm
          onCourseAdded={handleCourseAdded}
          onCancel={handleCancelCourseForm}
        />
      )}
      {showAddCategoryForm && (
        <AddCategoryForm
          onCategoryAdded={handleCategoryAdded}
          onCancel={handleCancelCategoryForm}
        />
      )}
      <CourseList
        courses={courses}
        onCourseUpdated={handleCourseUpdated}
        refreshCourses={fetchCourses}
      />
    </div>
  );
};

export default CoursesPage;
