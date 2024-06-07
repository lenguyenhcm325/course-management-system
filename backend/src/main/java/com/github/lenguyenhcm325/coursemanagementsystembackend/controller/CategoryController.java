package com.github.lenguyenhcm325.coursemanagementsystembackend.controller;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Category;
import com.github.lenguyenhcm325.coursemanagementsystembackend.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categories")
public class CategoryController {

  private final CategoryService categoryService;

  @Autowired
  public CategoryController(CategoryService categoryService) {
    this.categoryService = categoryService;
  }

  @PostMapping
  public ResponseEntity<Category> createCategory(@Valid @RequestBody Category category) {
    Category createdCategory = categoryService.saveCategory(category);
    return new ResponseEntity<>(createdCategory, HttpStatus.CREATED);
  }

  @GetMapping("/{id}")
  public ResponseEntity<Category> getCategoryById(@PathVariable int id) {
    Category category = categoryService.getCategoryById(id);
    if (category != null) {
      return new ResponseEntity<>(category, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @GetMapping
  public ResponseEntity<List<Category>> getAllCategories() {
    List<Category> categories = categoryService.getAllCategories();
    return new ResponseEntity<>(categories, HttpStatus.OK);
  }

  @PutMapping("/{id}")
  public ResponseEntity<Category> updateCategory(
      @PathVariable int id, @Valid @RequestBody Category updatedCategory) {
    Category existingCategory = categoryService.getCategoryById(id);
    if (existingCategory != null) {
      Category updated = categoryService.updateCategoryById(id, updatedCategory);
      return new ResponseEntity<>(updated, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteCategory(@PathVariable int id) {
    Category existingCategory = categoryService.getCategoryById(id);
    if (existingCategory != null) {
      categoryService.deleteCategoryById(id);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }
}
