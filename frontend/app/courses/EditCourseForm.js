"use client";

import axios from "axios";
import { useState, useEffect } from "react";
import styles from "./FormStyles.module.css";

const EditCourseForm = ({ course, onSave, onCancel }) => {
  const [providers, setProviders] = useState([]);
  const [categories, setCategories] = useState([]);
  const [updatedCourse, setUpdatedCourse] = useState({ ...course });

  useEffect(() => {
    const fetchProviders = async () => {
      const result = await axios.get("http://localhost:8080/providers");
      setProviders(result.data);
    };

    const fetchCategories = async () => {
      const result = await axios.get("http://localhost:8080/categories");
      setCategories(result.data);
    };

    fetchProviders();
    fetchCategories();
  }, []);

  useEffect(() => {
    // Format the dates to "YYYY-MM-DD"
    if (updatedCourse.startDate) {
      setUpdatedCourse((prevState) => ({
        ...prevState,
        startDate: new Date(prevState.startDate).toISOString().split("T")[0],
      }));
    }
    if (updatedCourse.endDate) {
      setUpdatedCourse((prevState) => ({
        ...prevState,
        endDate: new Date(prevState.endDate).toISOString().split("T")[0],
      }));
    }
  }, []);

  const handleInputChange = (e) => {
    const { name, value, options } = e.target;
    if (name === "categories") {
      const selectedCategories = Array.from(options)
        .filter((option) => option.selected)
        .map((option) => ({ id: option.value }));
      setUpdatedCourse((prevState) => ({
        ...prevState,
        categories: selectedCategories,
      }));
    } else if (name === "provider_id") {
      setUpdatedCourse((prevState) => ({
        ...prevState,
        provider: { id: value },
      }));
    } else {
      setUpdatedCourse((prevState) => ({
        ...prevState,
        [name]: value,
      }));
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    try {
      await axios.put(
        `http://localhost:8080/courses/${course.id}`,
        updatedCourse
      );
      onSave(updatedCourse);
    } catch (error) {
      console.error("There was an error updating the course!", error);
    }
  };

  return (
    <div className={styles.editCourseFormOverlay}>
      <div className={styles.editCourseFormContainer}>
        <h2>Edit Course</h2>
        <form onSubmit={handleSave}>
          <div>
            <label htmlFor="title">Title:</label>
            <input
              type="text"
              id="title"
              name="title"
              value={updatedCourse.title}
              onChange={handleInputChange}
              required
            />
          </div>
          <div>
            <label htmlFor="author">Author:</label>
            <input
              type="text"
              id="author"
              name="author"
              value={updatedCourse.author}
              onChange={handleInputChange}
              required
            />
          </div>
          <div>
            <label htmlFor="description">Description:</label>
            <textarea
              id="description"
              name="description"
              value={updatedCourse.description}
              onChange={handleInputChange}
              required
            />
          </div>
          <div>
            <label htmlFor="progress">Progress:</label>
            <input
              type="number"
              id="progress"
              name="progress"
              value={updatedCourse.progress}
              onChange={handleInputChange}
              required
              min="0"
              max="100"
            />
          </div>
          <div>
            <label htmlFor="courseProfileImageLink">Course Image Link:</label>
            <input
              type="text"
              id="courseProfileImageLink"
              name="courseProfileImageLink"
              value={updatedCourse.courseProfileImageLink}
              onChange={handleInputChange}
            />
          </div>
          <div>
            <label htmlFor="notes">Notes:</label>
            <textarea
              id="notes"
              name="notes"
              value={updatedCourse.notes}
              onChange={handleInputChange}
            />
          </div>
          <div>
            <label htmlFor="provider_id">Provider:</label>
            <select
              id="provider_id"
              name="provider_id"
              value={updatedCourse.provider.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Select a provider</option>
              {providers.map((provider) => (
                <option key={provider.id} value={provider.id}>
                  {provider.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor="startDate">Start Date:</label>
            <input
              type="date"
              id="startDate"
              name="startDate"
              value={updatedCourse.startDate}
              onChange={handleInputChange}
              max="9999-12-31"
              min="1000-01-01"
            />
          </div>
          <div>
            <label htmlFor="endDate">End Date:</label>
            <input
              type="date"
              id="endDate"
              name="endDate"
              value={updatedCourse.endDate}
              onChange={handleInputChange}
              max="9999-12-31"
              min="1000-01-01"
            />
          </div>
          <div className={styles.categorySection}>
            <label htmlFor="categories">Categories:</label>
            <select
              id="categories"
              name="categories"
              value={updatedCourse.categories.map((category) => category.id)}
              onChange={handleInputChange}
              multiple
              className={styles.multiSelect}
            >
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </div>
          <button type="submit">Save</button>
          <button
            type="button"
            onClick={onCancel}
            className={styles.cancelButton}
          >
            Cancel
          </button>
        </form>
      </div>
    </div>
  );
};

export default EditCourseForm;
