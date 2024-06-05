package com.github.lenguyenhcm325.coursemanagementsystembackend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
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

  @NotBlank
  @Size(max = 255)
  @Column(name = "title")
  private String title;

  @NotBlank
  @Size(max = 255)
  @Column(name = "author")
  private String author;

  @Min(0)
  @Max(100)
  @Column(name = "progress")
  private int progress;

  @Size(max = 255)
  @Column(name = "course_profile_image_link")
  private String courseProfileImageLink;

  @Size(max = 255)
  @Column(name = "notes")
  private String notes;

  @ManyToOne
  @JoinColumn(name = "provider_id", nullable = false)
  private Provider provider;

  @Size(max = 1023)
  @Column(name = "description")
  private String description;

  @Column(name = "start_date")
  private Date startDate;

  @Column(name = "end_date")
  private Date endDate;

  @Column(name = "created_at", updatable = false, insertable = false)
  private Timestamp createdAt;

  @Column(name = "updated_at", updatable = false, insertable = false)
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
