"use client";

import axios from "axios";
import { useEffect, useState } from "react";
import styles from "./FormStyles.module.css";

const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL;

const AddCourseForm = ({ onCourseAdded, onCancel }) => {
  const [providers, setProviders] = useState([]);
  const [categories, setCategories] = useState([]);
  const [newCourse, setNewCourse] = useState({
    title: "",
    author: "",
    progress: 0,
    courseProfileImageLink: "",
    notes: "",
    provider: { id: "" },
    description: "",
    startDate: "",
    endDate: "",
    categories: [],
  });
  const [newCategory, setNewCategory] = useState("");

  useEffect(() => {
    const fetchProviders = async () => {
      const result = await axios.get(`${backendUrl}/providers`);
      setProviders(result.data);
    };

    const fetchCategories = async () => {
      const result = await axios.get(`${backendUrl}/categories`);
      setCategories(result.data);
    };

    fetchProviders();
    fetchCategories();
  }, []);

  const handleInputChange = (e) => {
    const { name, value, options } = e.target;
    if (name === "categories") {
      const selectedCategories = Array.from(options)
        .filter((option) => option.selected)
        .map((option) => ({ id: option.value }));
      setNewCourse((prevState) => ({
        ...prevState,
        categories: selectedCategories,
      }));
    } else if (name === "provider_id") {
      setNewCourse((prevState) => ({
        ...prevState,
        provider: { id: value },
      }));
    } else {
      setNewCourse((prevState) => ({
        ...prevState,
        [name]: value,
      }));
    }
  };

  const handleAddCourse = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${backendUrl}/courses`, newCourse);
      onCourseAdded(response.data);
      setNewCourse({
        title: "",
        author: "",
        progress: 0,
        courseProfileImageLink: "",
        notes: "",
        provider: { id: "" },
        description: "",
        startDate: "",
        endDate: "",
        categories: [],
      });
    } catch (error) {
      console.error("There was an error adding the course!", error);
    }
  };

  return (
    <div className={styles.editCourseFormOverlay}>
      <div className={styles.editCourseFormContainer}>
        <h2>Add New Course</h2>
        <form onSubmit={handleAddCourse}>
          <div>
            <label htmlFor="title">Title:</label>
            <input
              type="text"
              id="title"
              name="title"
              value={newCourse.title}
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
              value={newCourse.author}
              onChange={handleInputChange}
              required
            />
          </div>
          <div>
            <label htmlFor="description">Description:</label>
            <textarea
              id="description"
              name="description"
              value={newCourse.description}
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
              value={newCourse.progress}
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
              value={newCourse.courseProfileImageLink}
              onChange={handleInputChange}
            />
          </div>
          <div>
            <label htmlFor="notes">Notes:</label>
            <textarea
              id="notes"
              name="notes"
              value={newCourse.notes}
              onChange={handleInputChange}
            />
          </div>
          <div>
            <label htmlFor="provider_id">Provider:</label>
            <select
              id="provider_id"
              name="provider_id"
              value={newCourse.provider.id}
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
              value={newCourse.startDate}
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
              value={newCourse.endDate}
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
              value={newCourse.categories.map((category) => category.id)}
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
          <button type="submit">Add Course</button>
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

export default AddCourseForm;
