"use client";

import axios from "axios";
import { useState } from "react";
import styles from "./FormStyles.module.css";

const backendUrl = process.env.BACKEND_URL;

const AddCategoryForm = ({ onCategoryAdded, onCancel }) => {
  const [categoryName, setCategoryName] = useState("");

  const handleInputChange = (e) => {
    setCategoryName(e.target.value);
  };

  const handleAddCategory = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${backendUrl}/categories`, {
        name: categoryName,
      });
      onCategoryAdded(response.data);
      setCategoryName("");
    } catch (error) {
      console.error("There was an error adding the category!", error);
    }
  };

  return (
    <div className={styles.editCourseFormOverlay}>
      <div className={styles.editCourseFormContainer}>
        <h2>Add New Category</h2>
        <form onSubmit={handleAddCategory}>
          <div>
            <label htmlFor="categoryName">Category Name:</label>
            <input
              type="text"
              id="categoryName"
              name="categoryName"
              value={categoryName}
              onChange={handleInputChange}
              required
            />
          </div>
          <button type="submit">Add Category</button>
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

export default AddCategoryForm;
