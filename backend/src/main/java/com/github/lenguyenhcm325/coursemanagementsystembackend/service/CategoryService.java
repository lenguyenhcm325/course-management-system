package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Category;
import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Provider;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.CategoryRepository;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

  private final CategoryRepository categoryRepository;
  private final EntityManager entityManager;

  @Autowired
  public CategoryService(CategoryRepository categoryRepository, EntityManager entityManager) {
    this.categoryRepository = categoryRepository;
    this.entityManager = entityManager;
  }

  public Category saveCategory(Category category) {
    return categoryRepository.save(category);
  }

  public Category getCategoryById(int id) {
    return categoryRepository.findById(id).orElse(null);
  }

  public List<Category> getAllCategories() {
    return categoryRepository.findAll();
  }

  public void deleteCategoryById(int id) {
    categoryRepository.deleteById(id);
  }

  public Category updateCategoryById(int id, Category category) {
    return categoryRepository
        .findById(id)
        .map(
            foundCategory -> {
              foundCategory.setName(category.getName());
              entityManager.flush();
              entityManager.refresh(foundCategory);
              return foundCategory;
            })
        .orElse(null);
  }
}
