package com.github.lenguyenhcm325.coursemanagementsystembackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Courses")
public class Course {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private int id;

  @Column(name = "title")
  private String title;

  @Column(name = "author")
  private String author;

  @Column(name = "progress")
  private int progress;

  @Column(name = "course_profile_image_link")
  private String courseProfileImageLink;

  @Column(name = "notes")
  private String notes;

  @ManyToOne
  @JoinColumn(name = "provider_id", nullable = false)
  private Provider provider;

  @Column(name = "description")
  private String description;

  @Column(name = "start_date")
  private Date startDate;

  @Column(name = "end_date")
  private Date endDate;

  @Column(name = "created_at")
  private Timestamp createdAt;

  @Column(name = "updated_at")
  private Timestamp updatedAt;

  @ManyToMany
  @JoinTable(
      name = "Course_Categories",
      joinColumns = @JoinColumn(name = "course_id"),
      inverseJoinColumns = @JoinColumn(name = "category_id"))
  private List<Category> categories;

  @Override
  public String toString() {
    return "Course{"
        + "id="
        + id
        + ", title='"
        + title
        + '\''
        + ", author='"
        + author
        + '\''
        + ", progress="
        + progress
        + ", courseProfileImageLink='"
        + courseProfileImageLink
        + '\''
        + ", notes='"
        + notes
        + '\''
        + ", provider="
        + provider
        + ", description='"
        + description
        + '\''
        + ", startDate="
        + startDate
        + ", endDate="
        + endDate
        + ", createdAt="
        + createdAt
        + ", updatedAt="
        + updatedAt
        + ", categories="
        + categories
        + '}';
  }
}
